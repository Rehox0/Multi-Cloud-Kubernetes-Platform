#!/usr/bin/env bash

set -Eeuo pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

EXPECTED_BRANCH="testing"

TERRAFORM_DIR="terraform/azure/envs/dev"

IDENTITY_DIR="k8s/gitops/infra/aws/identity"

CLIENT_ID_FILE="${IDENTITY_DIR}/values.yaml"
TENANT_ID_FILE="${IDENTITY_DIR}/azure-workload-identity.yaml"

COMMIT_MESSAGE="chore(gitops): sync Azure workload identity IDs"

# --------------------------------------------------
# Locate repository
# --------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"

cd "${REPO_ROOT}"

# --------------------------------------------------
# Validate environment
# --------------------------------------------------

if ! command -v terraform >/dev/null 2>&1; then
    echo "ERROR: terraform is not installed or is not in PATH." >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is not installed or is not in PATH." >&2
    exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"

if [[ "${CURRENT_BRANCH}" != "${EXPECTED_BRANCH}" ]]; then
    echo "ERROR: Expected branch '${EXPECTED_BRANCH}', current branch is '${CURRENT_BRANCH}'." >&2
    echo "Switch branches before running this script." >&2
    exit 1
fi

if [[ ! -d "${TERRAFORM_DIR}" ]]; then
    echo "ERROR: Terraform directory not found: ${TERRAFORM_DIR}" >&2
    exit 1
fi

# --------------------------------------------------
# Read Terraform outputs
# --------------------------------------------------

echo "Reading Terraform outputs..."

CLIENT_ID="$(
    terraform -chdir="${TERRAFORM_DIR}" \
        output -raw eks_backend_identity_client_id
)"

TENANT_ID="$(
    terraform -chdir="${TERRAFORM_DIR}" \
        output -raw azure_tenant_id
)"

if [[ -z "${CLIENT_ID}" ]]; then
    echo "ERROR: eks_backend_identity_client_id is empty." >&2
    exit 1
fi

if [[ -z "${TENANT_ID}" ]]; then
    echo "ERROR: azure_tenant_id is empty." >&2
    exit 1
fi

# Basic validation: both values should be UUIDs.
UUID_REGEX='^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$'

if [[ ! "${CLIENT_ID}" =~ ${UUID_REGEX} ]]; then
    echo "ERROR: Client ID is not a valid UUID: ${CLIENT_ID}" >&2
    exit 1
fi

if [[ ! "${TENANT_ID}" =~ ${UUID_REGEX} ]]; then
    echo "ERROR: Tenant ID is not a valid UUID: ${TENANT_ID}" >&2
    exit 1
fi

echo "Client ID: ${CLIENT_ID}"
echo "Tenant ID: ${TENANT_ID}"

# --------------------------------------------------
# Update GitOps values
# --------------------------------------------------

mkdir -p "${IDENTITY_DIR}"

export CLIENT_ID TENANT_ID CLIENT_ID_FILE TENANT_ID_FILE

python3 <<'PYTHON'
import os
import re
from pathlib import Path


client_id = os.environ["CLIENT_ID"]
tenant_id = os.environ["TENANT_ID"]

client_file = Path(os.environ["CLIENT_ID_FILE"])
tenant_file = Path(os.environ["TENANT_ID_FILE"])


def update_nested_client_id(path: Path, value: str) -> None:
    """
    Update backend.workloadIdentity.clientId while preserving
    unrelated values in the YAML file.

    Create the expected structure if the file does not exist.
    """
    if not path.exists():
        path.write_text(
            "backend:\n"
            "  workloadIdentity:\n"
            f'    clientId: "{value}"\n',
            encoding="utf-8",
        )
        print(f"Created {path}")
        return

    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)

    # Locate the top-level backend mapping.
    backend_index = next(
        (
            i for i, line in enumerate(lines)
            if re.match(r"^backend\s*:\s*(?:#.*)?(?:\r?\n)?$", line)
        ),
        None,
    )

    if backend_index is None:
        if lines and not lines[-1].endswith("\n"):
            lines[-1] += "\n"

        lines.extend([
            "backend:\n",
            "  workloadIdentity:\n",
            f'    clientId: "{value}"\n',
        ])
        path.write_text("".join(lines), encoding="utf-8")
        print(f"Added backend.workloadIdentity.clientId to {path}")
        return

    # Find the end of the backend block: the next non-empty,
    # non-comment top-level key.
    backend_end = len(lines)

    for i in range(backend_index + 1, len(lines)):
        line = lines[i]

        if line.strip() and not line.lstrip().startswith("#"):
            if not line[0].isspace():
                backend_end = i
                break

    # Find workloadIdentity within the backend block.
    workload_index = next(
        (
            i for i in range(backend_index + 1, backend_end)
            if re.match(r"^  workloadIdentity\s*:\s*(?:#.*)?(?:\r?\n)?$", lines[i])
        ),
        None,
    )

    if workload_index is None:
        lines.insert(
            backend_end,
            "  workloadIdentity:\n"
            f'    clientId: "{value}"\n',
        )
        path.write_text("".join(lines), encoding="utf-8")
        print(f"Added backend.workloadIdentity.clientId to {path}")
        return

    # Find the end of the workloadIdentity block.
    workload_end = backend_end

    for i in range(workload_index + 1, backend_end):
        line = lines[i]

        if line.strip() and not line.lstrip().startswith("#"):
            if not line.startswith("    "):
                workload_end = i
                break

    # Replace clientId if it exists in the expected block.
    client_index = next(
        (
            i for i in range(workload_index + 1, workload_end)
            if re.match(r"^    clientId\s*:", lines[i])
        ),
        None,
    )

    replacement = f'    clientId: "{value}"\n'

    if client_index is not None:
        lines[client_index] = replacement
    else:
        lines.insert(workload_end, replacement)

    path.write_text("".join(lines), encoding="utf-8")
    print(f"Updated {path}")


def update_tenant_id(path: Path, value: str) -> None:
    """
    Update the top-level azureTenantID key expected by
    the Azure Workload Identity webhook Helm chart.
    """
    if not path.exists():
        path.write_text(
            f'azureTenantID: "{value}"\n',
            encoding="utf-8",
        )
        print(f"Created {path}")
        return

    text = path.read_text(encoding="utf-8")

    pattern = re.compile(r"^azureTenantID\s*:.*$", re.MULTILINE)
    replacement = f'azureTenantID: "{value}"'

    if pattern.search(text):
        text = pattern.sub(replacement, text, count=1)
    else:
        if text and not text.endswith("\n"):
            text += "\n"

        text += replacement + "\n"

    path.write_text(text, encoding="utf-8")
    print(f"Updated {path}")


update_nested_client_id(client_file, client_id)
update_tenant_id(tenant_file, tenant_id)

PYTHON

# --------------------------------------------------
# Review changes
# --------------------------------------------------

echo
echo "Changes in the identity values files:"
git --no-pager diff -- "${CLIENT_ID_FILE}" "${TENANT_ID_FILE}"

# Include untracked files in the change check.
CHANGES="$(git status --short -- "${CLIENT_ID_FILE}" "${TENANT_ID_FILE}")"

if [[ -z "${CHANGES}" ]]; then
    echo
    echo "No changes detected. Nothing to commit."
    exit 0
fi

# --------------------------------------------------
# Commit only the two target files
# --------------------------------------------------

echo
echo "Creating commit..."

git add -- "${CLIENT_ID_FILE}" "${TENANT_ID_FILE}"

git commit --only \
    -m "${COMMIT_MESSAGE}" \
    -- "${CLIENT_ID_FILE}" "${TENANT_ID_FILE}"

echo
echo "SUCCESS: Identity values synchronized and committed."
echo "Branch: ${CURRENT_BRANCH}"
echo "Files:"
echo "  - ${CLIENT_ID_FILE}"
echo "  - ${TENANT_ID_FILE}"
echo
echo "No git push was performed."
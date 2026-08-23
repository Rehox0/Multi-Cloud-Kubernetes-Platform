from django.http import JsonResponse

def video(request):
    return JsonResponse({"module": "Video", "status": "Streaming active", "items": ["movie1", "movie2", "movie3"]})

def shop(request):
    return JsonResponse({"module": "Shop", "status": "Open", "items": ["hat", "shirt", "shoes"]})

def payments(request):
    return JsonResponse({"module": "Payments", "status": "Gateway ready", "balance": 150.00})
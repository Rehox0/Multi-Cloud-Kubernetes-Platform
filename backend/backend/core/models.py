from django.db import models


class Event(models.Model):
    event_type = models.CharField(max_length=50)
    value = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
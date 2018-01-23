from django.urls import path

from . import views

urlpatterns = [
    path('', views.reading_time, name='reading_time')
]

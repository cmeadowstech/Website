from django.contrib import admin
from .models import Project

# Register your models here.

@admin.register(Project)
class PojectAdmin(admin.ModelAdmin):
    list_display = ('title', 'url')

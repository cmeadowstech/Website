from django.db import models

# Create your models here.

class Project(models.Model):
    title = models.CharField(max_length=30, help_text='The title of the project')
    url = models.URLField(help_text='The URL for the project\'s repo or blog post', blank=True)
    tech = models.CharField(max_length=200, help_text='Comma separated list of technologies used by the project')
    synopsis = models.TextField(help_text='Summary of the project')
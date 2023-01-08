from django.db import models
from django.urls import reverse
from django.utils.text import slugify

# Create your models here.

class Project(models.Model):
    title = models.CharField(max_length=30, help_text='The title of the project')
    url = models.URLField(help_text='The URL for the project\'s repo or blog post', blank=True)
    tech = models.CharField(max_length=200, help_text='Comma separated list of technologies used by the project')
    synopsis = models.TextField(help_text='Summary of the project')
    article = models.TextField(blank=True, help_text="Full article on the project, in markdown")
    slug = models.SlugField(max_length=250, blank=True)

    def get_absolute_url(self):
        kwargs = {
            'pk': self.id,
            'slug': self.slug
        }
        return reverse("project-detail", kwargs=kwargs)

    def save(self, *args, **kwargs):
        value = self.title
        self.slug = slugify(value, allow_unicode=True)
        super().save(*args, **kwargs)
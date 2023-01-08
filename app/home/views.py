from django.shortcuts import render
from .models import Project
from django.views import generic
from django.http import JsonResponse

# Create your views here.

def home(request):
    projects = Project.objects.all()

    context = {
        'projects': projects
    }

    return render(request, 'index.html', context=context)

class projectDetailView(generic.DetailView):
    model = Project
    query_pk_and_slug = True
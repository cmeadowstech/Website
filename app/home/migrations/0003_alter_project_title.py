# Generated by Django 4.1.4 on 2022-12-29 21:55

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0002_alter_project_url'),
    ]

    operations = [
        migrations.AlterField(
            model_name='project',
            name='title',
            field=models.CharField(help_text='The title of the project', max_length=30),
        ),
    ]
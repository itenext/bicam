from django.core.management.base import BaseCommand
from django.utils.text import slugify
from pages.models import Medicine


class Command(BaseCommand):
    help = 'Populate slugs for existing Medicine records'

    def handle(self, *args, **options):
        medicines = Medicine.objects.filter(slug__isnull=True)
        updated_count = 0
        
        for medicine in medicines:
            medicine.slug = slugify(medicine.name)
            medicine.save()
            updated_count += 1
            self.stdout.write(
                self.style.SUCCESS(f'Updated slug for: {medicine.name} -> {medicine.slug}')
            )
        
        self.stdout.write(
            self.style.SUCCESS(f'\nTotal records updated: {updated_count}')
        )

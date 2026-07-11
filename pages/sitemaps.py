from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from .models import Medicine

class StaticSitemap(Sitemap):
    priority = 0.8
    changefreq = "monthly"

    def items(self):
        return ['index', 'about', 'contact', 'medicines']  # Ensure these are correct URL names

    def location(self, item):
        return reverse(item)


class MedicineSitemap(Sitemap):
    priority = 0.9
    changefreq = "weekly"

    def items(self):
        return Medicine.objects.all()

    def location(self, obj):
        return reverse('medicine_detail', args=[obj.slug])  # Ensure 'medicine_detail' is the correct URL name

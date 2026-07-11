from django.db import models
from django.utils.text import slugify

# Create your models here.

class Medicine(models.Model):
    name = models.CharField(max_length=255, unique=True)
    slug = models.SlugField(unique=True, blank=True)  
    title = models.TextField()
    ingredients = models.TextField()
    recommendation = models.TextField()
    dose = models.TextField()
    features = models.TextField()
    indications = models.TextField()
    image = models.ImageField(upload_to='medicine_images/', null=True, blank=True)

    meta_title = models.CharField(max_length=255, blank=True, null=True) 
    meta_description = models.TextField(blank=True, null=True) 

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)  
        if not self.meta_title:
            self.meta_title = f"{self.name} - Best Veterinary Medicine | Bichem Laboratories"
        if not self.meta_description:
            self.meta_description = f"Buy {self.name}, a trusted veterinary medicine. Learn more about its indications, dosage, and benefits."
        super().save(*args, **kwargs)
    
    def get_absolute_url(self):
        from django.urls import reverse
        return reverse('product_detail', kwargs={'slug': self.slug})
    
    @property
    def description(self):
        """Use title as description for SEO purposes"""
        return self.title[:200] + "..." if len(self.title) > 200 else self.title

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Medicine"
        verbose_name_plural = "Medicines"



from django.contrib import admin
from .models import Medicine  # Import the Medicine model

# Register the model
@admin.register(Medicine)
class MedicineAdmin(admin.ModelAdmin):
    list_display = ('name', 'title', 'image')


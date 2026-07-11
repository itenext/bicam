from django.shortcuts import render, get_object_or_404
from django.core.paginator import Paginator
from django.http import HttpResponse
from django.template.loader import render_to_string
from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from .models import Medicine


def product_wording(value):
    if not value:
        return value
    return (
        value.replace('Medicines', 'Products')
        .replace('medicines', 'products')
        .replace('Medicine', 'Product')
        .replace('medicine', 'product')
    )
 
 
def index(request):
    featured_products = Medicine.objects.exclude(image='').order_by('name')[:6]
    return render(request, 'index.html', {'featured_products': featured_products})

def about(request):
    return render(request, 'about.html')

def contact(request):
    return render(request, 'contact.html')

# def medicines(request):
#     return render(request, 'medicines.html')

def diseases(request):
    return render(request, 'diseases.html')


def testimonials(request):
    return render(request, 'testimonials.html')



def medicines(request):
    medicines = Medicine.objects.all()  
    return render(request, 'medicines.html', {'medicines': medicines})


def medicine_detail(request, slug):
    medicine = get_object_or_404(Medicine, slug=slug)
    return render(request, 'medicine_detail.html', {
        'medicine': medicine,
        'product': medicine,
        'related_products': Medicine.objects.exclude(pk=medicine.pk).order_by('name')[:4],
        'canonical_url': f'https://bichemlaboratories.com/medicines/{medicine.slug}/',
        'image_url': f'https://bichemlaboratories.com{medicine.image.url}' if medicine.image else None,
        'meta_title': product_wording(medicine.meta_title),
        'meta_description': product_wording(medicine.meta_description),
    })


# New SEO-optimized product views
def product_list(request):
    """Product list view with pagination and SEO optimization"""
    products = Medicine.objects.all().order_by('name')
    
    # Pagination
    paginator = Paginator(products, 12)  # 12 products per page
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'products': page_obj,
        'canonical_url': 'https://bichemlaboratories.com/products/',
    }
    return render(request, 'products/list.html', context)


def product_detail(request, slug):
    """Product detail view with full SEO optimization"""
    product = get_object_or_404(Medicine, slug=slug)
    related_products = Medicine.objects.exclude(pk=product.pk).order_by('name')[:4]
    
    # Generate absolute URLs
    canonical_url = f'https://bichemlaboratories.com/products/{product.slug}/'
    image_url = f'https://bichemlaboratories.com{product.image.url}' if product.image else None
    
    context = {
        'product': product,
        'canonical_url': canonical_url,
        'image_url': image_url,
        'related_products': related_products,
        'meta_title': product_wording(product.meta_title) or f"{product.name} - Veterinary Product | Bichem Laboratories",
        'meta_description': product_wording(product.meta_description) or product_wording(product.description) or product_wording(product.title[:160]),
    }
    return render(request, 'products/detail.html', context)


def robots_txt(request):
    """Serve robots.txt"""
    content = """User-agent: *
Allow: /
Sitemap: https://bichemlaboratories.com/sitemap.xml
"""
    return HttpResponse(content, content_type='text/plain')


def sitemap_xml(request):
    """Generate sitemap.xml"""
    products = Medicine.objects.all()
    
    sitemap_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
    sitemap_content += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    
    # Add static pages
    static_pages = [
        ('', '1.0', 'daily'),
        ('/about/', '0.8', 'monthly'),
        ('/contact/', '0.8', 'monthly'),
        ('/products/', '0.9', 'weekly'),
        ('/diseases/', '0.7', 'monthly'),
        ('/testimonials/', '0.7', 'monthly'),
    ]
    
    for url, priority, changefreq in static_pages:
        sitemap_content += f'  <url>\n'
        sitemap_content += f'    <loc>https://bichemlaboratories.com{url}</loc>\n'
        sitemap_content += f'    <lastmod>2025-01-01</lastmod>\n'
        sitemap_content += f'    <changefreq>{changefreq}</changefreq>\n'
        sitemap_content += f'    <priority>{priority}</priority>\n'
        sitemap_content += f'  </url>\n'
    
    # Add product pages
    for product in products:
        sitemap_content += f'  <url>\n'
        sitemap_content += f'    <loc>https://bichemlaboratories.com/products/{product.slug}/</loc>\n'
        sitemap_content += f'    <lastmod>2025-01-01</lastmod>\n'
        sitemap_content += f'    <changefreq>weekly</changefreq>\n'
        sitemap_content += f'    <priority>0.9</priority>\n'
        sitemap_content += f'  </url>\n'
    
    sitemap_content += '</urlset>'
    
    return HttpResponse(sitemap_content, content_type='application/xml')

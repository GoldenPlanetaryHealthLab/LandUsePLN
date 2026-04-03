from country_bounding_boxes import (
      country_subunits_by_iso_code
    )

def get_bounding_box_for_iso_code(iso_code):
    
    subunits = list(country_subunits_by_iso_code(iso_code))
    
    if not subunits:
        raise ValueError(f"No country found with ISO code: {iso_code}")
    if len(subunits) > 1:
        raise ValueError(f"Multiple countries found with ISO code: {iso_code}")
    return subunits[0]

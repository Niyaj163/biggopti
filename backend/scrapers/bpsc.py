import re
from bs4 import BeautifulSoup
from .base_scraper import BaseScraper
from typing import List, Dict, Any

class BPSCScraper(BaseScraper):
    """Scraper for Bangladesh Public Service Commission (BPSC)."""

    def __init__(self):
        super().__init__(
            name="BPSC",
            source_url="https://bpsc.gov.bd/site/view/notices"
        )

    def scrape_notices(self) -> List[Dict[str, Any]]:
        html = self.fetch_page(self.source_url)
        if not html:
            return []

        soup = BeautifulSoup(html, 'html.parser')
        notices = []

        # Parse notice table links
        for a_tag in soup.find_all('a', href=re.compile(r'\.pdf$', re.IGNORECASE)):
            href = a_tag.get('href')
            title = a_tag.get_text(strip=True)
            
            if not href.startswith('http'):
                pdf_url = f"https://bpsc.gov.bd{href}" if href.startswith('/') else f"https://bpsc.gov.bd/{href}"
            else:
                pdf_url = href

            if title and pdf_url:
                notices.append({
                    'title': title,
                    'pdf_url': pdf_url,
                    'org_name': 'বাংলাদেশ সরকারি কর্ম কমিশন (BPSC)',
                    'category': 'govt'
                })

        return notices[:5] # Process latest 5 notices

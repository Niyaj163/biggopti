import re
from bs4 import BeautifulSoup
from .base_scraper import BaseScraper
from typing import List, Dict, Any

class DPEScraper(BaseScraper):
    """Scraper for Directorate of Primary Education (DPE) Recruitment Notices."""

    def __init__(self):
        super().__init__(
            name="DPE",
            source_url="https://dpe.gov.bd/site/view/notices"
        )

    def scrape_notices(self) -> List[Dict[str, Any]]:
        html = self.fetch_page(self.source_url)
        if not html:
            return []

        soup = BeautifulSoup(html, 'html.parser')
        notices = []

        for row in soup.find_all('tr'):
            cols = row.find_all('td')
            if len(cols) >= 2:
                title = cols[1].get_text(strip=True) if len(cols) > 1 else ""
                pdf_a = row.find('a', href=lambda h: h and '.pdf' in h.lower())
                if pdf_a and title:
                    href = pdf_a.get('href')
                    if not href.startswith('http'):
                        pdf_url = f"https://dpe.gov.bd/{href.lstrip('/')}"
                    else:
                        pdf_url = href

                    notices.append({
                        'title': title,
                        'pdf_url': pdf_url,
                        'org_name': 'প্রাথমিক শিক্ষা অধিদপ্তর (DPE)',
                        'category': 'govt'
                    })

        return notices[:15]

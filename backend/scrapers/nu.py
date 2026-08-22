import re
from bs4 import BeautifulSoup
from .base_scraper import BaseScraper
from typing import List, Dict, Any

class NUScraper(BaseScraper):
    """Scraper for National University (NU) Notice Board."""

    def __init__(self):
        super().__init__(
            name="NationalUniversity",
            source_url="https://www.nu.ac.bd/recent-news-notice.php"
        )

    def scrape_notices(self) -> List[Dict[str, Any]]:
        html = self.fetch_page(self.source_url)
        if not html:
            return []

        soup = BeautifulSoup(html, 'html.parser')
        notices = []

        # Find all PDF links on the notice board
        for a_tag in soup.find_all('a', href=re.compile(r'\.pdf$', re.IGNORECASE)):
            href = a_tag.get('href')
            title = a_tag.get_text(strip=True)

            if not title and a_tag.parent:
                title = a_tag.parent.get_text(strip=True)

            if not href.startswith('http'):
                pdf_url = f"https://www.nu.ac.bd/{href.lstrip('/')}"
            else:
                pdf_url = href

            if title and pdf_url:
                notices.append({
                    'title': title,
                    'pdf_url': pdf_url,
                    'org_name': 'জাতীয় বিশ্ববিদ্যালয় (National University)',
                    'category': 'varsity'
                })

        return notices[:15]  # Process up to 15 latest real notices

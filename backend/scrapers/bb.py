import re
from bs4 import BeautifulSoup
from .base_scraper import BaseScraper
from typing import List, Dict, Any

class BangladeshBankScraper(BaseScraper):
    """Scraper for Bangladesh Bank (Central Bank) Career Section."""

    def __init__(self):
        super().__init__(
            name="BangladeshBank",
            source_url="https://erecruitment.bb.org.bd/onlineapp/joblist.php"
        )

    def scrape_notices(self) -> List[Dict[str, Any]]:
        html = self.fetch_page(self.source_url)
        if not html:
            return []

        soup = BeautifulSoup(html, 'html.parser')
        notices = []

        for a_tag in soup.find_all('a', href=re.compile(r'\.pdf$', re.IGNORECASE)):
            href = a_tag.get('href')
            title = a_tag.get_text(strip=True) or "বাংলাদেশ ব্যাংক নিয়োগ বিজ্ঞপ্তি"
            
            pdf_url = href if href.startswith('http') else f"https://erecruitement.bb.org.bd/onlineapp/{href.lstrip('/')}"
            
            notices.append({
                'title': title,
                'pdf_url': pdf_url,
                'org_name': 'বাংলাদেশ ব্যাংক (Central Bank)',
                'category': 'bank'
            })

        return notices[:15]  # Process up to 15 latest real notices

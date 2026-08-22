import re
from bs4 import BeautifulSoup
from .base_scraper import BaseScraper
from typing import List, Dict, Any

class NUScraper(BaseScraper):
    """Scraper for National University (NU) Academic & Job Notices."""

    def __init__(self):
        super().__init__(
            name="NationalUniversity",
            source_url="https://www.nu.ac.bd/recent-news-notice.php"
        )
        self.blacklist_patterns = [
            'cv_', 'cv of', 'biodata', 'profile_pdf', 'about national university',
            'about_national', 'টেন্ডার', 'দরপত্র', 'অফিস আদেশ', 'ছুটি', 'বদলি',
            'সংবর্ধনা', 'প্রেস রিলিজ', 'press-release', 'shok_shongbad'
        ]
        self.whitelist_keywords = [
            'ভর্তি', 'পরীক্ষা', 'নিয়োগ', 'রুটিন', 'ফর্ম পূরণ', 'ফরম পূরণ',
            'রেজিস্ট্রেশন', 'ফলাফল', 'সময়সূচি', 'বিজ্ঞপ্তি', 'স্কলারশিপ',
            'বৃত্তি', 'সার্কুলার', 'admission', 'exam', 'routine', 'circular', 'job'
        ]

    def _is_relevant_notice(self, title: str, href: str) -> bool:
        low_title = title.lower()
        low_href = href.lower()

        # Check blacklist first
        for bad in self.blacklist_patterns:
            if bad in low_title or bad in low_href:
                return False

        # Check whitelist keywords
        for good in self.whitelist_keywords:
            if good in low_title or good in low_href:
                return True

        return False

    def scrape_notices(self) -> List[Dict[str, Any]]:
        html = self.fetch_page(self.source_url)
        if not html:
            return []

        soup = BeautifulSoup(html, 'html.parser')
        notices = []

        # Find PDF notice links in NU notice tables
        for a_tag in soup.find_all('a', href=re.compile(r'\.pdf$', re.IGNORECASE)):
            href = a_tag.get('href', '').strip()
            title = a_tag.get_text(strip=True)

            if not title and a_tag.parent:
                title = a_tag.parent.get_text(strip=True)

            if not title or not href:
                continue

            if not self._is_relevant_notice(title, href):
                continue

            if not href.startswith('http'):
                pdf_url = f"https://www.nu.ac.bd/{href.lstrip('/')}"
            else:
                pdf_url = href

            notices.append({
                'title': title,
                'pdf_url': pdf_url,
                'org_name': 'জাতীয় বিশ্ববিদ্যালয় (National University)',
                'category': 'varsity'
            })

        return notices[:15]

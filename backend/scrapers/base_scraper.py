import hashlib
import requests
import urllib3
from typing import List, Dict, Any

# Disable SSL warnings for Bangladeshi national portal certs
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class BaseScraper:
    """Base class for all Bangladeshi notice scrapers."""
    
    def __init__(self, name: str, source_url: str):
        self.name = name
        self.source_url = source_url
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'bn,en-US;q=0.7,en;q=0.3',
        }

    def compute_hash(self, content: bytes) -> str:
        """Compute SHA256 hash of PDF bytes for deduplication."""
        return hashlib.sha256(content).hexdigest()

    def fetch_page(self, url: str) -> str | None:
        """Fetch HTML page content with retry logic."""
        try:
            res = requests.get(url, headers=self.headers, verify=False, timeout=20)
            if res.status_code == 200:
                res.encoding = 'utf-8'
                return res.text
        except Exception as e:
            print(f"[{self.name}] Failed to fetch page {url}: {e}")
        return None

    def fetch_pdf_bytes(self, pdf_url: str) -> bytes | None:
        """Download raw PDF bytes."""
        try:
            res = requests.get(pdf_url, headers=self.headers, verify=False, timeout=25)
            if res.status_code == 200 and len(res.content) > 100:
                return res.content
        except Exception as e:
            print(f"[{self.name}] Failed to download PDF {pdf_url}: {e}")
        return None

    def scrape_notices(self) -> List[Dict[str, Any]]:
        """Must be implemented by subclasses to return notice metadata dicts."""
        raise NotImplementedError

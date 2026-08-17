import hashlib
import requests
from typing import List, Dict, Any

class BaseScraper:
    """Base class for all Bangladeshi notice scrapers."""
    
    def __init__(self, name: str, source_url: str):
        self.name = name
        self.source_url = source_url
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }

    def compute_hash(self, content: bytes) -> str:
        """Compute SHA256 hash of PDF bytes for deduplication."""
        return hashlib.sha256(content).hexdigest()

    def fetch_page(self, url: str) -> str | None:
        """Fetch HTML page content with retry logic."""
        try:
            res = requests.get(url, headers=self.headers, timeout=15)
            if res.status_code == 200:
                return res.text
        except Exception as e:
            print(f"[{self.name}] Failed to fetch page {url}: {e}")
        return None

    def fetch_pdf_bytes(self, pdf_url: str) -> bytes | None:
        """Download raw PDF bytes."""
        try:
            res = requests.get(pdf_url, headers=self.headers, timeout=20)
            if res.status_code == 200:
                return res.content
        except Exception as e:
            print(f"[{self.name}] Failed to download PDF {pdf_url}: {e}")
        return None

    def scrape_notices(self) -> List[Dict[str, Any]]:
        """Must be implemented by subclasses to return notice metadata dicts."""
        raise NotImplementedError

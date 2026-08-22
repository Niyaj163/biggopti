import os
import json
import io
from pathlib import Path
import pdfplumber
from google import genai
from google.genai import types

class AIParser:
    """Gemini 3.6 Flash Bangla PDF Circular Digest Engine with Multimodal Fallback."""

    def __init__(self, api_key: str):
        self.client = genai.Client(api_key=api_key)
        self.prompt_path = Path(__file__).resolve().parent / 'prompts' / 'parse_circular.txt'
        self.master_prompt = self._load_prompt()

    def _load_prompt(self) -> str:
        if self.prompt_path.exists():
            with open(self.prompt_path, 'r', encoding='utf-8') as f:
                return f.read()
        return "Extract structured Bangla notice JSON with title, org_name, category, deadline, age_limit, eligibility, summary_bullets."

    def extract_text_from_pdf(self, pdf_bytes: bytes) -> str:
        """Extract text from PDF using pdfplumber."""
        extracted_text = ""
        try:
            with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
                for page in pdf.pages[:5]:  # Process up to 5 pages
                    text = page.extract_text()
                    if text:
                        extracted_text += text + "\n"
        except Exception as e:
            print(f"[AIParser] pdfplumber extraction note: {e}")
        return extracted_text.strip()

    def parse_circular(self, pdf_bytes: bytes, pdf_url: str, pdf_hash: str) -> dict | None:
        """Parse circular into structured Bangla JSON with multimodal scanned PDF support."""
        text = self.extract_text_from_pdf(pdf_bytes)

        try:
            # If pdfplumber extracted meaningful text, use text prompt
            if text and len(text) > 80:
                truncated_text = text[:4000]
                contents = [
                    self.master_prompt,
                    f"Notice Source URL: {pdf_url}\n\nNotice PDF Text:\n{truncated_text}"
                ]
            else:
                # Multimodal Fallback: Pass raw PDF bytes directly to Gemini 3.6 Flash for native OCR
                print(f"[AIParser] Scanned/image PDF detected. Using Gemini direct multimodal OCR...")
                contents = [
                    self.master_prompt,
                    types.Part.from_bytes(data=pdf_bytes[:4000000], mime_type='application/pdf'),
                    f"Notice Source URL: {pdf_url}"
                ]

            response = self.client.models.generate_content(
                model='gemini-3.6-flash',
                contents=contents,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.1,
                ),
            )

            if response.text:
                parsed_json = json.loads(response.text)

                # Strict validation: Reject if AI flagged as invalid (CV, office order, etc.)
                if parsed_json.get('is_valid_circular') is False:
                    print(f"[AIParser] Discarded non-job document: {parsed_json.get('title', 'Unknown')}")
                    return None

                # Discard if generic placeholder is present in title or bullets
                bullets = parsed_json.get('summary_bullets', [])
                bullets_text = " ".join(bullets)
                if 'পিডিএফ কন্টেন্ট বিস্তারিত পাওয়া যায় নি' in bullets_text or 'বিস্তারিত পাওয়া যায় নি' in bullets_text:
                    print(f"[AIParser] Discarded low-quality / empty placeholder output for: {pdf_url}")
                    return None

                parsed_json['original_pdf_url'] = pdf_url
                parsed_json['pdf_hash'] = pdf_hash
                parsed_json['source'] = 'scraped'
                return parsed_json
        except Exception as e:
            print(f"[AIParser] Gemini Flash API parsing error: {e}")

        return None

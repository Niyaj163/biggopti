import os
import json
import io
from pathlib import Path
import pdfplumber
from google import genai
from google.genai import types

class AIParser:
    """Gemini 2.5 Flash Bangla PDF Circular Digest Engine."""

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
                for page in pdf.pages[:4]: # Limit to first 4 pages for speed
                    text = page.extract_text()
                    if text:
                        extracted_text += text + "\n"
        except Exception as e:
            print(f"[AIParser] pdfplumber extraction error: {e}")
        return extracted_text.strip()

    def parse_circular(self, pdf_bytes: bytes, pdf_url: str, pdf_hash: str) -> dict | None:
        """Parse circular text into structured Bangla JSON via Gemini 2.5 Flash."""
        text = self.extract_text_from_pdf(pdf_bytes)
        
        # Truncate to ~4,000 chars for optimal latency and free tier efficiency
        truncated_text = text[:4000] if text else "Notice PDF content unavailable"
        
        full_content = f"{self.master_prompt}\n\nNotice Source URL: {pdf_url}\n\nNotice PDF Text:\n{truncated_text}"

        try:
            response = self.client.models.generate_content(
                model='gemini-2.5-flash',
                contents=full_content,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.2,
                ),
            )

            if response.text:
                parsed_json = json.loads(response.text)
                parsed_json['original_pdf_url'] = pdf_url
                parsed_json['pdf_hash'] = pdf_hash
                parsed_json['source'] = 'scraped'
                return parsed_json
        except Exception as e:
            print(f"[AIParser] Gemini Flash API parsing error: {e}")

        return None

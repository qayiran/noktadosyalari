import asyncio
import urllib.request
import os
import re
from playwright.async_api import async_playwright

async def get_pinterest_feed():
    async with async_playwright() as p:
        user_data = os.path.expanduser("~/.config/chromium") 
        
        print("Downgrading from 'Originals' to '736x' because Qayiran is confusing! 🙄")
        try:
            browser = await p.chromium.launch_persistent_context(
                user_data_dir=user_data,
                executable_path='/usr/bin/chromium', 
                headless=True,
                viewport={'width': 1920, 'height': 1080} 
            )
            page = await browser.new_page()
            
            await page.goto("https://www.pinterest.com/homefeed/")
            await asyncio.sleep(8) 
            
            pin_link_element = await page.query_selector('div[data-test-id="pin"] a')
            if not pin_link_element:
                print("No pins found! I'm blaming your internet connection! 💢")
                await browser.close()
                return

            pin_url = await pin_link_element.get_attribute("href")
            full_pin_url = f"https://www.pinterest.com{pin_url}"
            print(f"Jumping to Pin: {full_pin_url}")

            await page.goto(full_pin_url)
            await asyncio.sleep(6) 
            
            # Look at all images on the pin page
            images = await page.query_selector_all('img')
            
            high_res_url = None
            for img in images:
                src = await img.get_attribute("src")
                
                # If it's a valid pin image, let's just force it to be exactly 736x
                if src and re.search(r'/(236x|474x|564x|736x)/', src):
                    print(f"Found the source: {src}")
                    # Instead of originals, we strictly request the 736x high-quality display version!
                    high_res_url = re.sub(r'/(236x|474x|564x)/', '/736x/', src)
                    break 
            
            if high_res_url:
                print(f"Downloading your precious 736x version: {high_res_url} ✨")
                opener = urllib.request.build_opener()
                opener.addheaders = [('User-agent', 'Mozilla/5.0')]
                urllib.request.install_opener(opener)
                
                urllib.request.urlretrieve(high_res_url, "/tmp/pinterest_widget.jpg")
                print("Success! It better be sharp enough for your elite Arch setup now! 💖")
            else:
                print("Couldn't find any image! I'm going to scream! 🤬")

            await browser.close()
        except Exception as e:
            print(f"Error: {e} ...Don't look at me, I didn't do it! 🫣")

asyncio.run(get_pinterest_feed())

from hijridate import Gregorian
import datetime

# I made a dictionary for you. Don't break it!
# If you want a different language, just change the strings on the right.
hijri_months = {
    1: "Muharrëm",
    2: "Safër",
    3: "Rebii ül-Evvël",
    4: "Rebii ül-Aahir",
    5: "Cemaazii el-Evvël",
    6: "Cemaazii el-Aahir",
    7: "Recep",
    8: "Şaaban",
    9: "Ramazan",
    10: "Şevva’l",
    11: "Zi l-kaade",
    12: "Zi l-hicce"
}

def fetch_hijri_date():
    today = datetime.date.today()
    hijri = Gregorian(today.year, today.month, today.day).to_hijri()
    
    # Grab the translated name using the month number
    month_name = hijri_months[hijri.month]
    
    # Print it with your precious dot.
    print(f"{hijri.day} {month_name}.")

if __name__ == "__main__":
    fetch_hijri_date()

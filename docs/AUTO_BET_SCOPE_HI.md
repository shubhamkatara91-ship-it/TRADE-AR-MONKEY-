# ARG V1 Auto-Bet Scope (Hindi)

## निर्णय

TRADE AR MONEY में **वास्तविक पैसे से अपने-आप bet लगाने वाला फीचर implement या enable नहीं किया जाएगा**। वर्तमान ARG V1 को practice-only रखा जाएगा।

भारत के Promotion and Regulation of Online Gaming Act, 2025 में online money games और उनसे जुड़ी offering/facilitation पर रोक का प्रावधान है। केंद्र सरकार की 22 अप्रैल 2026 की आधिकारिक जानकारी के अनुसार संबंधित Act/Rules 1 मई 2026 से लागू हुए। लागू होने की तारीख पर स्रोत:
- https://www.indiacode.nic.in/indiacode/handle/123456789/22148
- https://www.pib.gov.in/PressReleasePage.aspx?PRID=2254606&lang=1&reg=3

यह तकनीकी/उत्पाद-स्तर का compliance guard है, व्यक्तिगत कानूनी सलाह नहीं। कोई भी अलग प्रस्तावित product model पहले भारत में योग्य वकील से लिखित समीक्षा कराए।

## सुरक्षित विकल्प जो ऐप में उपलब्ध/जोड़ा जा सकता है

- Auto-practice toggle: चालू/बंद।
- हर local minute पर चुना हुआ BIG या SMALL अभ्यास विकल्प history में दर्ज करना।
- साफ disclosure कि यह prediction नहीं है, official provider round ID नहीं है, और कोई पैसा/वास्तविक bet submit नहीं होती।
- Stop control और सीमित local practice history।

## Real-money integration के लिए स्थिति

किसी तीसरे पक्ष के WinGo/BDG/Mark Pro endpoint, private API, login session या payment flow को reverse-engineer करके real bets submit नहीं किए जाएंगे। किसी API का URL या server string मिल जाना अनुमति का प्रमाण नहीं है। इस repository में कोई verified, authorized wagering API या लिखित authorization स्थापित नहीं है।

## Release gate

1. Practice mode default और स्पष्ट रूप से labeled रहे।
2. Auto-practice केवल local practice history लिखे; कोई payment, wallet, wager, external POST या bet placement न हो।
3. कोई live-feed configuration मिले तो केवल अधिकृत read-only result feed के रूप में, लिखित अनुमति और schema validation के बाद विचार करें।
4. Release से पहले automated build और device testing करें; build success को live service verification न मानें।

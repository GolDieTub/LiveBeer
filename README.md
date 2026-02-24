# Project Overview

This project is a demonstration iOS application built with SwiftUI.

---

## Authentication

- User registration is implemented with a phone number flow.  
- A mock verification code hint is used instead of real SMS confirmation.  
- Real SMS verification via Firebase was intentionally not integrated due to cost constraints.  
- All user data is stored locally on the device.  
- Each registered phone number is associated with a unique generated barcode.  

---

## Data Handling

- News content is fetched using the NewsAPI (https://newsapi.org) service (beer-related news).  
- Promotional offers are loaded locally.  
- User accounts and profile data are stored locally.  
- Randomized map addresses are used for demonstration purposes.  

---

## UX / UI

- The interface is built fully with SwiftUI.  
- Several UX and UI elements were customized and extended beyond the base implementation.  
- Animations, validation feedback, and form state handling were added to improve interaction clarity.  

---

## Notes

This project is intended for demonstration and architectural showcase purposes.

It does **not** include:

- Production-ready backend integration  
- Real SMS verification  

# Freshtrack Mobile

Welcome to the first release of **Freshtrack Mobile**!

Freshtrack is a Flutter-based mobile application designed to help you manage your inventory, with a primary focus on tracking expiration dates to ensure product freshness. This application connects to the Freshtrack backend (freshtrack.azurewebsites.net) for _real-time_ data synchronization.

## Key Features

- **Secure Login & Logout**: Sign in to the system with your account and log out securely.

- **Inventory Management**:
  - View a complete list of items along with their total stock.
  - View item details per batch, including stock and expiration dates.

- **Smart Expiry Tracking**:
  - Monitor the remaining days before items expire.
  - Get clear visual status (Green: Safe, Orange: Check Soon, Red: Expired) through both icons and text colors.
  - Special text display for items expiring today (`Today`) or already expired (`Expired`).

- **Transaction Recording**:
  - Record incoming item transactions, complete with expiration dates.
  - Record outgoing item transactions.

- **Item Registration (Admin)**: Admins can register new items into the system.

- **Transaction History (Admin)**:
  - View the history of all transactions.
  - Filter history based on a date range.
  - Print transaction history to PDF format.

- **Item Management (Admin)**: Admins can edit and delete item data.

- **Search & Sort**: Easily search for items and sort data in the inventory and expiry tables.

- **Responsive Interface**: Table views adjust to screen size.

- **GitHub Actions CI**: A basic workflow to build the Android APK automatically is set up.

## Assets in This Release

- `app-release.apk`: The installation file for Android devices.

## How to Install

1. Download the `app-release.apk` file from the assets below.
2. Open the file on your Android device.
3. You might need to allow installation from "Unknown Sources" in your device's security settings.
4. Follow the installation prompts until finished.

---

Thank you for using Freshtrack! We look forward to your feedback.

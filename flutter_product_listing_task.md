# Product Listing App

## 1. Objective

Build a simple Flutter application that fetches products from a DummyJSON API and displays them in a product listing screen.

The application should demonstrate basic API integration, UI development, state management using Provider, navigation between screens, and handling loading and error states.

Users should be able to browse products, view product details, and refresh the product list.

## 2. API Details

**Endpoint:** https://dummyjson.com/products

- **Method:** GET
- No authentication required.
- Do not hardcode product data.
- Use the API response to display products.

## 3. Functional Requirements

### A. Product Listing Screen

Create a product listing screen with the following elements:

- An app bar with the title `Products`.
- Display products in a two-column grid.
- Each product card should display:
  - Product image.
  - Product name.
  - Product price.

**Expected behaviour:**

- Tapping a product card should navigate to its details screen.
- Pass the selected product's data to the details screen. Do not make a separate API call to fetch product details.
- Long product names should be handled without UI overflow.
- Display the products using a clean and simple UI.

### B. Product Details Screen

Create a separate screen to display the selected product's details.

Display the following information:

- Product image.
- Product name.
- Product price.
- Product description.

**Expected behaviour:**

- Open this screen when the user taps a product in the listing.
- Display the details of the selected product.
- Provide a back button to return to the product listing screen.

### C. API Integration

- Fetch products from the DummyJSON API.
- Create a `ProductModel` class to parse the API response.
- Keep API logic separate from the UI.
- Use a repository class to handle the API request and JSON parsing.

### D. Provider State Management

Use the `provider` package to manage the application state.

The Provider class should:

- Fetch and maintain the list of products.
- Manage the loading state.
- Manage API errors.
- Notify the UI when the state changes using `notifyListeners()`.

### E. Loading, Success and Error States

Implement all three states for fetching products.

**Loading state**
- Display a `CircularProgressIndicator` while the API request is in progress.

**Success state**
- Display the product grid after successfully fetching the products.

**Error state**
- Display a meaningful error message if the API request fails.
- Provide a `Retry` button to fetch the products again.

### F. Pull-to-Refresh

Implement pull-to-refresh functionality using Flutter's `RefreshIndicator`.

Requirements:

- Allow users to pull down on the product listing screen to refresh the product list.
- Fetch the latest product data from the API.
- Show the refresh indicator while the request is in progress.
- Update the UI when the request completes.

## 4. Suggested Project Structure

Keep the project structure simple and beginner-friendly.

```text
lib/
├── main.dart
├── models/
│   └── product_model.dart
├── repositories/
│   └── product_repository.dart
├── providers/
│   └── product_provider.dart
└── screens/
    ├── product_list_screen.dart
    └── product_details_screen.dart
```

### File Responsibilities

| File | Responsibility |
|---|---|
| `main.dart` | Configure `MaterialApp` and register Provider. |
| `product_model.dart` | Convert JSON data into a Dart object. |
| `product_repository.dart` | Make API requests and parse the response. |
| `product_provider.dart` | Manage products, loading and errors. |
| `product_list_screen.dart` | Display the product grid and handle refresh. |
| `product_details_screen.dart` | Display the selected product's details. |

## 5. Packages to Use

Add the following dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  http: ^1.5.0
```

Use Flutter's built-in widgets for navigation, layouts, loading indicators and pull-to-refresh.

## 6. Acceptance Criteria

- [ ] Products are fetched from the API without hardcoding product data.
- [ ] Products are displayed in a two-column grid.
- [ ] Product images, names and prices are displayed correctly.
- [ ] Loading, success and error states are handled.
- [ ] The Retry button works when an API request fails.
- [ ] Tapping a product opens the product details screen.
- [ ] Product details display the correct information.
- [ ] Pull-to-refresh fetches the latest product data.
- [ ] API logic is separated from the UI.
- [ ] Provider is used for state management.
- [ ] Long product names do not cause UI overflow.
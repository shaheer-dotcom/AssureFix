# Requirements Document

## Introduction

This feature ensures that user profile pictures are properly displayed on the home screens for both customer and service provider panels in the AssureFix mobile application. Currently, the customer home screen shows a blue circle placeholder instead of the actual profile picture, and the service provider home screen does not display a profile picture at all. This feature will implement consistent profile picture display across both user types.

## Glossary

- **Home Screen**: The main landing screen users see after logging into the application
- **Profile Picture**: The user's uploaded profile image stored in the backend
- **Customer Panel**: The interface and screens accessible to users with customer role
- **Service Provider Panel**: The interface and screens accessible to users with service provider role
- **Avatar Widget**: A circular UI component that displays the profile picture or fallback placeholder
- **API Base URL**: The backend server URL used to construct full image URLs
- **Fallback Avatar**: A placeholder avatar showing the user's initial when no profile picture exists

## Requirements

### Requirement 1

**User Story:** As a customer, I want to see my profile picture on the home screen, so that I can confirm I'm logged into the correct account

#### Acceptance Criteria

1. WHEN the Customer Home Screen loads, THE System SHALL display the user's profile picture in a circular avatar widget
2. WHEN the profile picture URL is valid, THE System SHALL load and display the image from the backend server
3. IF the profile picture fails to load, THEN THE System SHALL display a fallback avatar with the user's first initial
4. WHERE no profile picture exists, THE System SHALL display a fallback avatar with the user's first initial

### Requirement 2

**User Story:** As a service provider, I want to see my profile picture on the home screen, so that I can verify my account identity at a glance

#### Acceptance Criteria

1. WHEN the Service Provider Home Screen loads, THE System SHALL display the user's profile picture in a circular avatar widget
2. WHEN the profile picture URL is valid, THE System SHALL load and display the image from the backend server
3. IF the profile picture fails to load, THEN THE System SHALL display a fallback avatar with the user's first initial
4. WHERE no profile picture exists, THE System SHALL display a fallback avatar with the user's first initial

### Requirement 3

**User Story:** As a user, I want the profile picture to be displayed consistently across both customer and service provider panels, so that the interface feels cohesive

#### Acceptance Criteria

1. THE System SHALL display profile pictures with identical styling on both customer and service provider home screens
2. THE System SHALL use a circular avatar with a radius of 30 pixels for profile pictures on home screens
3. THE System SHALL position the profile picture to the left of the welcome message on both home screens
4. THE System SHALL apply the primary theme color as the background for fallback avatars

### Requirement 4

**User Story:** As a developer, I want proper error handling for profile picture loading, so that image loading failures do not crash the application

#### Acceptance Criteria

1. WHEN a profile picture image fails to load, THE System SHALL catch the error and display the fallback avatar
2. THE System SHALL log image loading errors for debugging purposes without exposing them to users
3. THE System SHALL construct image URLs using the correct API base URL configuration
4. THE System SHALL handle null or empty profile picture values gracefully by showing the fallback avatar

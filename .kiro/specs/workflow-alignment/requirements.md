# Requirements Document

## Introduction

This document outlines the requirements for aligning the AssureFix service booking application with the complete workflow specification. The system enables customers to find and book services from service providers, with comprehensive profile management, messaging, booking management, and admin oversight capabilities.

## Glossary

- **System**: The AssureFix mobile and web application
- **Customer**: A user who searches for and books services
- **Service Provider**: A user who posts and provides services
- **Admin**: System administrator with oversight and management capabilities
- **Booking**: A scheduled service appointment between a customer and service provider
- **Active Booking**: A booking with status 'pending', 'confirmed', or 'in_progress'
- **Service Tag**: A searchable keyword associated with a service name or area
- **OTP**: One-Time Password sent via email for verification
- **Profile Banner**: A background image displayed on service provider profiles
- **Notification**: System-generated alert sent to users about bookings, messages, or updates

## Requirements

### Requirement 1: User Authentication and Registration

**User Story:** As a new user, I want to register with my email and password and verify my account via OTP, so that I can securely access the platform.

#### Acceptance Criteria

1. WHEN a user opens the application, THE System SHALL display a login/signup form
2. WHEN a user enters valid credentials and has an existing account, THE System SHALL navigate the user to their respective home page
3. WHEN a user selects signup, THE System SHALL collect email and password
4. WHEN a user submits signup form, THE System SHALL send an OTP to the provided email address
5. WHEN a user enters the correct OTP within the expiry time, THE System SHALL verify the email and navigate to role selection screen
6. IF the OTP is incorrect or expired, THEN THE System SHALL display an error message and allow retry

### Requirement 2: Role Selection and Profile Creation

**User Story:** As a verified user, I want to select my role (customer or service provider) and complete my profile, so that I can use the platform according to my needs.

#### Acceptance Criteria

1. WHEN email verification is complete, THE System SHALL display a role selection screen with options for customer and service provider
2. WHERE the user selects service provider, THE System SHALL request profile picture, banner image, name, phone number, email (auto-filled), CNIC picture, and shop documents
3. WHERE the user selects customer, THE System SHALL request profile picture, name, phone number, email (auto-filled), and CNIC picture
4. WHEN the user submits the profile creation form with all required fields, THE System SHALL store the profile data in the database
5. WHEN profile creation is successful, THE System SHALL navigate the user to their role-specific home screen

### Requirement 3: Service Provider - Service Management

**User Story:** As a service provider, I want to post, manage, and track my services, so that customers can find and book them.

#### Acceptance Criteria

1. WHEN a service provider accesses "Post a service", THE System SHALL collect service name, description, area tags, and price per hour
2. WHEN a service provider submits a service with all required fields, THE System SHALL store the service and make it searchable
3. WHEN a service provider accesses "Manage services", THE System SHALL display all posted services with name, areas covered, price per hour, and ratings
4. WHEN a service provider clicks on a service card, THE System SHALL display detailed view including description and customer reviews
5. WHERE a service matches both the service name tag AND at least one area tag from customer search, THE System SHALL include it in search results

### Requirement 4: Service Provider - Booking Management

**User Story:** As a service provider, I want to view and manage my bookings, so that I can track my work and complete services.

#### Acceptance Criteria

1. WHEN a service provider accesses "Manage Bookings", THE System SHALL display separate lists for active, completed, and cancelled bookings
2. WHEN a service provider views an active booking, THE System SHALL display service name, customer name, date, time, price, and complete address
3. WHEN a service provider clicks "completed" on an active booking, THE System SHALL prompt for customer rating and review
4. WHEN a service provider submits rating and review, THE System SHALL update booking status to completed and store the rating
5. WHEN a service provider attempts to edit a completed or cancelled booking, THE System SHALL prevent the action
6. WHEN a customer books a service, THE System SHALL send a notification to the service provider

### Requirement 5: Service Provider - Home Screen and Notifications

**User Story:** As a service provider, I want to see my active bookings and receive notifications, so that I can stay informed about my business.

#### Acceptance Criteria

1. WHEN a service provider accesses the home screen, THE System SHALL display a welcome message with the provider's name
2. WHEN a service provider clicks the notification button, THE System SHALL display booking notifications, admin messages, and app updates
3. WHEN a service provider views the home screen, THE System SHALL display active bookings with service name, customer name, address, date, time, and price
4. WHEN a service provider clicks "completed" on a home screen booking, THE System SHALL prompt for rating and move booking to completed status
5. WHEN a new booking is created, THE System SHALL generate a notification for the service provider

### Requirement 6: Customer - Service Search and Booking

**User Story:** As a customer, I want to search for services by name and area, so that I can find and book the services I need.

#### Acceptance Criteria

1. WHEN a customer accesses "Search A service", THE System SHALL display fields for service name tag and area location tag
2. WHEN a customer clicks "find services", THE System SHALL return services matching the service name AND at least one area tag
3. WHEN search results are displayed, THE System SHALL show service name, provider name, areas covered, ratings, and price for each service
4. WHEN a customer clicks on a service, THE System SHALL display detailed view with name, description, areas, provider name, price, ratings, and reviews
5. WHEN a customer clicks "book service", THE System SHALL collect customer name, phone number, complete address, date, and time
6. WHEN a customer submits booking form, THE System SHALL create the booking and send notification to the service provider

### Requirement 7: Customer - Booking Management

**User Story:** As a customer, I want to manage my bookings, so that I can track, modify, or cancel my scheduled services.

#### Acceptance Criteria

1. WHEN a customer accesses "Manage Bookings", THE System SHALL display separate lists for active, completed, and cancelled bookings
2. WHEN a customer views an active booking, THE System SHALL display service name, provider name, date, time, price, and complete address
3. WHEN a customer clicks an active booking, THE System SHALL allow editing of date, time, address, name, and phone number
4. WHEN a customer clicks "cancel" on an active booking, THE System SHALL update status to cancelled
5. WHEN a customer clicks "completed" on an active booking, THE System SHALL prompt for provider rating and review
6. WHEN a customer attempts to edit a completed or cancelled booking, THE System SHALL prevent the action

### Requirement 8: Messaging System

**User Story:** As a user, I want to message other users involved in my bookings, so that I can communicate about service details.

#### Acceptance Criteria

1. WHEN a user accesses the messages screen, THE System SHALL display all conversations with users from active bookings
2. WHEN a user opens a conversation, THE System SHALL display all previous messages
3. WHILE a booking status is active, THE System SHALL allow sending text messages, voice notes, location, and images
4. WHEN a booking status is completed or cancelled, THE System SHALL display previous messages but prevent sending new messages
5. WHEN a user sends a message, THE System SHALL send a notification to the recipient
6. WHEN a user receives a message, THE System SHALL display a notification

### Requirement 9: Profile and Settings Management

**User Story:** As a user, I want to view and edit my profile and settings, so that I can maintain my account information and preferences.

#### Acceptance Criteria

1. WHEN a user accesses the profile screen, THE System SHALL display profile information and average ratings
2. WHEN a user clicks on ratings, THE System SHALL display detailed ratings and reviews from individual users
3. WHEN a user accesses settings, THE System SHALL provide options to change password with email OTP verification
4. WHEN a user toggles theme setting, THE System SHALL switch between dark mode and light mode
5. WHEN a user accesses help and support, THE System SHALL display customer support contact details and FAQs

### Requirement 10: Report and Block Functionality

**User Story:** As a user, I want to report or block other users, so that I can manage my interactions and safety on the platform.

#### Acceptance Criteria

1. WHEN a user views another user's profile, THE System SHALL display report and block buttons
2. WHEN a user clicks report, THE System SHALL record the report for admin review
3. WHEN a user clicks block, THE System SHALL prevent future interactions between the users
4. WHEN a user accesses "Report and block" section, THE System SHALL display all reported and blocked users
5. WHEN a user clicks unblock, THE System SHALL restore the ability to interact with the previously blocked user

### Requirement 11: Admin Portal - User Management

**User Story:** As an admin, I want to manage customers and service providers, so that I can maintain platform quality and safety.

#### Acceptance Criteria

1. WHEN an admin logs in with email shaheer13113@gmail.com, THE System SHALL navigate to the admin portal
2. WHEN an admin accesses user management, THE System SHALL display separate lists for customers and service providers
3. WHEN an admin clicks on a user, THE System SHALL display detailed user information
4. WHEN an admin clicks ban on a user, THE System SHALL deactivate the user account and prevent login
5. WHEN an admin clicks unban on a banned user, THE System SHALL reactivate the user account

### Requirement 12: Admin Portal - Reports and Notifications

**User Story:** As an admin, I want to review reports and send notifications, so that I can address issues and communicate with users.

#### Acceptance Criteria

1. WHEN an admin accesses reports, THE System SHALL display separate lists for customer reports and service provider reports
2. WHEN an admin views a report, THE System SHALL display the reporter, reported user, and report details
3. WHEN an admin accesses notifications, THE System SHALL provide options to send messages to individual users or all users
4. WHEN an admin sends a notification to a user, THE System SHALL deliver it to the user's notification section
5. WHEN an admin sends a broadcast notification, THE System SHALL deliver it to all users' notification sections

### Requirement 13: Profile Picture and Banner Management

**User Story:** As a service provider, I want to upload a profile picture and banner image, so that I can present my business professionally.

#### Acceptance Criteria

1. WHEN a service provider uploads a profile picture during registration, THE System SHALL store the image and associate it with the profile
2. WHEN a service provider uploads a banner image during registration, THE System SHALL store the image and display it on the profile
3. WHEN a service provider edits their profile, THE System SHALL allow updating profile picture and banner image
4. WHEN images are uploaded, THE System SHALL validate file type and size
5. WHEN a profile is viewed, THE System SHALL display the profile picture and banner image

### Requirement 14: Document Upload and Verification

**User Story:** As a service provider, I want to upload CNIC and shop documents, so that I can verify my identity and business.

#### Acceptance Criteria

1. WHEN a service provider uploads CNIC picture during registration, THE System SHALL store the document
2. WHERE a service provider has shop documents, THE System SHALL allow uploading shop documents during registration
3. WHEN documents are uploaded, THE System SHALL validate file type and size
4. WHEN an admin views a service provider profile, THE System SHALL display uploaded documents for verification
5. WHEN a customer uploads CNIC picture during registration, THE System SHALL store the document

### Requirement 15: Area Tag Matching for Service Discovery

**User Story:** As a customer, I want services to be matched based on area tags, so that I can find services available in my location.

#### Acceptance Criteria

1. WHEN a service provider posts a service, THE System SHALL store area tags as searchable fields
2. WHEN a customer searches with an area tag, THE System SHALL match services where at least one area tag matches
3. WHEN search results are displayed, THE System SHALL show all matching area tags for each service
4. WHEN a service provider adds multiple area tags, THE System SHALL display them as tag bubbles in the interface
5. WHEN a customer enters an area tag, THE System SHALL display it as a tag bubble in the search interface

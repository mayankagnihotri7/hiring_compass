# Hiring Compass

A RESTful API for a job board platform where recruiters can post jobs and applicants can apply without creating accounts.

## Features
- **Authentication**
- **Job Management** - Create, update and delete job postings
- **Smart Filtering** - Search and filter jobs by technology, category, salary and location.
- **Applications** - Apply to job without signing up.
- **Email Notifications** - Automated status update emails.
- **Authorizations** - Pundit based permissions.
- **Rate Limiting** - Protection against spam.
- **Resume Upload** - Active storage for resume attachments.
- **Application Tracking** - Status updates - (pending, reviewed, shortlisted, rejected, hired).

## Tech Stack
- Ruby on rails 7.2 (API only).
- PostgreSQL.
- ActiveStorage for file uploads.
- ActionMailer for emails.
- Pundit for authorization.
- Devise and Devise token auth.

## Getting Started
## Prerequisites
- Ruby 3.2.2
- PostgreSQL
- Node.js (for ActiveStorage)

## Installation
```bash
# Clone the repository
git clone https://github.com/mayankagnihotri7/hiring_compass.git
cd hiring-compass

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails s
```
The API will be available at `http://localhost:3000`

## API Documentation
## Authentication
Certain endpoints require authentication for actions for who post jobs, update, etc.

## Jobs
### List all jobs
GET /api/v1/jobs

**Query Parameters**
- `q` - Search by title or company.
- `category` - Filter by category (tech, marketing, sales, design, product, finance, operations).
- `technology` - Filter by technology name.
- `location` - Filter by location.
- `min_salary` - Minimum salary.
- `max_salary` - Maximum salary.
- `years_of_experience` - Maximum years required.
- `status` - Job status (open, closed, paused).

**Example**
GET /api/v1/jobs?category=tech&technology=ruby&min_salary=8000

### Get a single job
GET /api/v1/jobs/:id

### Create a job (requires authentication)
POST /api/v1/jobs

**Request body:**
```json
{
  "job": {
    "title": "Senior Ruby Developer",
    "description": "We're looking for...",
    "company_name": "Wayne Corp",
    "category": "tech",
    "location": "Gotham City",
    "status": "open",
    "currency": "USD",
    "min_salary": "80000",
    "max_salary": "120000",
    "years_of_experience": 5,
    "technologies": [{ "name": "ruby" }, { "name": "rails" }]
  }
}
```

### Update a job (requires authentication)
PUT /api/v1/jobs/:id
`Same request body as create.`

### Delete a job (requires authentication)
DELETE /api/v1/jobs/:id

### Get job categories
GET /api/v1/categories

```json
{
  "categories": [
    "tech",
    "sales",
    "marketing",
    "design",
    "product",
    "finance",
    "operations"
  ]
}
```

### Technologies

### List all technologies
GET /api/v1/technologies

### Job Application

### List applications for a job (requires authentication)
GET /api/v1/jobs/:job_id/job_applications

### Apply to a job (no authentication required)
POST /api/v1/jobs/:job_id/applications

**Request (multipart/form-data):**
```
job_application[first_name]: Bruce
job_application[last_name]: Wayne
job_application[email]: brucewayne@waynecorp.org
job_application[phone_number]: +1 555 123 4567
job_application[years_of_experience]: 5
job_application[visa_sponsorship_required]: false
resume: <file>
```

### Get application details
GET /api/v1/jobs/:job_id/job_applications/:id

### Update application status (authentication required)
PUT /api/v1/jobs/:job_id/job_applications/:id

**Request body**
```json
{
    "status": "shortlisted"
}
```

**Available statuses:** `pending`, `reviewed`, `shortlisted`, `rejected`, `hired`, `withdrawn`.

### Download resume (requires authentication)
GET /api/v1/:job_id/job_applications/:id/download

## Email Notifications

Applicants receive emails when:
- Application is received (automatic).
- Status is updated to reviewed, shortlisted, rejected or hired.

## Authorization
- Only job owners or admin can update/delete their jobs.
- Only job owners can view and update applications for their jobs.
- Anyone can view open jobs and apply.

## Rate Limiting
- API requests are rate limited to prevent abouse.
- Limits vary by endpoint.

## Development

### Running Tests
```bash
rspec
```

### Seed data
```bash
rails db:seed
```

This creates sample users, jobs, technologies and applications.

## Contributing
Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## License
This project is open source and licensed under the MIT license.

Project Link: [https://github.com/mayankagnihotri7/hiring_compass](https://github.com/mayankagnihotri7/hiring_compass)


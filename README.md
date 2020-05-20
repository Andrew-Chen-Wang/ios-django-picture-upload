# Uploading Pictures from iOS to Django and S3

By: Andrew Chen Wang

Created: 18 May 2020

This application also contains the Django server running with DRF and SimpleJWT in order to demonstrate how apps should communicate with JWT (an access and refresh token).

This application uses boto3 to create presigned POST urls to bypass the Django server altogether.

---
### How to setup

1. Clone or download this repository
2. To run the server, create a virtual environment `virtualenv venv && source venv/bin/activate`, install packages `pip install -r requirements.txt` -- the requirements.txt file is inside the server subdirectory -- and do `python manage.py migrate && python manage.py runserver`.
    - Again, make sure when you do this, you are inside the server directory on your terminal/cmd.
    - On Windows, you should do `venv\Scripts\activate` instead of `source venv/bin/activate`

A default user with the username `test` and password `test` have been created.

**When going into production (and testing for android), you'll want to change the urls in the code obviously. For Android, there are specific instructions on configuration for BOTH local and production.**

---
### Technical Details

- Django 3.0.3 and DRF 3.11.0 + SimpleJWT 4.4.0
- Swift 5.1 for development

---
### License

```
Copyright 2020 Andrew Chen Wang

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

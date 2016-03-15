//
//  EHConstant.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#ifndef __Easy_Hire__EHConstant__
#define __Easy_Hire__EHConstant__

#include <stdio.h>

#define LOGIN_URL @"http://easyhire-api.connect2projects.com/auth/token"
#define RELOGIN_URL @"http://easyhire-api.connect2projects.com/users/my-info"
#define REGISTRATION_URL @"http://easyhire-api.connect2projects.com/admin/users"
#define GET_OTP_URL @"http://easyhire-api.connect2projects.com/admin/users/%d/send-otp"
#define SEND_OTP_URL @"http://easyhire-api.connect2projects.com/admin/users/%d/activate"

#define CATEGORIES_LIST_URL @"http://easyhire-api.connect2projects.com/categories"

#define EQUIPMENTS_LIST_URL @"http://easyhire-api.connect2projects.com/equipments"

#define NOTIFICATION_SHOW_RELOGIN @"EasyHireSignoutNotification"

#define EQUIPMENT_OWNED_URL @"http://easyhire-api.connect2projects.com/users/%ld/equipments"

#define REQUIREMENT_LIST @"http://easyhire-api.connect2projects.com/requirements"
#define REQUIREMENT_LIST_DELETE @"http://easyhire-api.connect2projects.com/requirements/%ld"
#define REQUIREMENT_LIST_CREATE @"http://easyhire-api.connect2projects.com/requirements"
#define REQUIREMENT_LIST_MODIFY @"http://easyhire-api.connect2projects.com/requirement/%ld"

#define VEHICLE_GPS_LOCATION @"http://103.19.88.35/ITLFMSAPI/ITLFMSAPI.svc/GetVehicleDetails?UserId=landmaster&Password=welcome&vehicleno=%@"

#define CHANGE_PASSWORD @"http://easyhire-api.connect2projects.com/users/change-password"

#define MY_NOTIFICATION @"http://easyhire-api.connect2projects.com/my-notifications"

#define MY_NOTIFICATION_ACCEPT @"http://easyhire-api.connect2projects.com/notification/%d"
#define MY_NOTIFICATION_REJECT @"http://easyhire-api.connect2projects.com/notification/%d"

#define LOCATION_API @"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4&input=%@"

#define COORDINATE_API @"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4"

#define CUSTOMER_CARE_SERVICE @"http://easyhire-api.connect2projects.com/enquiry" // post method - mobile_number, contact_mode --- 0 -> call me back, 1 for toll free

#define FORGOT_PASSWORD @"http://easyhire-api.connect2projects.com/admin/users/forgot-password"

#define CAPACITY_URL @"http://easyhire-api.connect2projects.com/capacity"
#define BRAND_URL @"http://easyhire-api.connect2projects.com/brands"


#endif /* defined(__Easy_Hire__EHConstant__) */



// Vender
/*
After login & Registration
1 - Notification Screen
    Mapview and ListView - users/{id}/equipments
 
 Screen - Notifcation for vender, Equipment owned by vendor,
 
 
 Hirer
 1- Post your requitemnt
GET - Equipment-  /equipments


*/
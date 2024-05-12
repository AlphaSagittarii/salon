#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~~ Your Hair Salon ~~~~\n\n"
echo -e "Welcome to My Salon, how can I help you?\n"
SERVICES_MENU() {
  if [[ $1 ]]
  then
   echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  INPUT "$SERVICE_ID_SELECTED"
}

INPUT() {

  case $1 in
    1) SCHEDULE ;;
    2) SCHEDULE ;;
    3) SCHEDULE ;;
    *) SERVICES_MENU "I could not find that service. What would you like today?\n" ;;
  esac
}

SCHEDULE() {
  if [[ $1 ]]
  then
   echo -e "\n$1"
  fi
  # read service_id, phone, name and time
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if doesn't exist 
  if [[ -z $CUSTOMER_PHONE_RESULT ]]
  then
    # get customer info
    echo -e "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer 
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi
  
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # get service_time
  echo -e "\nPlease enter a valid time between 8am and 6pm:"
  read SERVICE_TIME
  if [[ ! $SERVICE_TIME =~ ^(8|9|1[0-1]|12)am|^(1[0-2]|[1-5])pm|^6pm$ ]]
  then
      SCHEDULE "This is not a valid time."
  else
      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "I have put you down for a$SELECTED_SERVICE at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
}

SERVICES_MENU
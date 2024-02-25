#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#Main menu function
MAIN_MENU() {
  echo -e "\n~~~ Salon ~~~\n"
  echo -e "Welcome to the salon, how can we assist you today?\n"

  #Display services offered with format "#) <service>"
  SERVICES=$($PSQL "SELECT * FROM services;")

  echo "$SERVICES" | while read ID BAR NAME
    do
      echo -e "$ID) $NAME"
    done
  
  #Read service input into SERVICE_ID_SELECTED
  read SERVICE_ID_SELECTED
  #If service doesn't exist, back to same list of services
  case $SERVICE_ID_SELECTED in
    1) BOOKING ;;
    2) BOOKING ;;
    3) BOOKING ;;
    *) MAIN_MENU ;;
  esac
}

BOOKING() {
  #If service exists
  if [[ $SERVICE_ID_SELECTED ]]
  then
    #Get the service name and format it to remove spaces
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_FORMATTED=$(echo $SERVICE | sed 's/( )*([a-z]+)/$2/')

    #Read phone number into CUSTOMER_PHONE and search customer table for an existing customer
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #If not a customer
      if [[ -z $CUSTOMER_NAME ]]
      then
        #Read name into CUSTOMER_NAME
        echo -e "\nPlease enter your name:"
        read CUSTOMER_NAME

        #Create customer in customer table
        INPUT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    
    #Get the customer ID from customer table to allow input to appointment table
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^( )*([a-z]+)( )*$/$2/')
    
    #Ask a time for appointment into SERVICE_TIME
    echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    #Input appointment into appointments table
    INPUT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    #Output "I have put you down for a <service> at <time>, <name>."
    echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU

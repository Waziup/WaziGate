# How to Use ZTE MF667 LTE USB Modem with Wazigate
This guide shows how to use a gsm modem with the WaziGate.

1. **Identify USB IDs:**
   - Plug in your ZTE MF667 LTE USB modem to your Wazigate device.
   - Open a terminal and run the following command to list USB devices and their IDs:
     ```
     lsusb
     ```
   - Look for the ZTE MF667 in the list. It should show you the vendor ID and product ID (e.g., `12d1:14fe`).

2. **Load the USB Serial Driver:**
   - Edit the `/etc/modules` file with superuser privileges to add the USB serial driver configuration. Replace `insert_vendor_id_here` and `insert_product_id_here` with the actual IDs from step 1:
     ```
     sudo nano /etc/modules
     ```
   - Add the following line at the end of the file:
     ```
     usbserial vendor=insert_vendor_id_here product=insert_product_id_here
     ```
   - Save the file and exit the text editor.

3. **Restart ModemManager:**
   - Restart the ModemManager service to apply the changes:
     ```
     sudo systemctl restart ModemManager
     ```

4. **Create a NetworkManager Connection:**
   - Use the `nmcli` command to create a new GSM (mobile broadband) connection with the ZTE MF667 modem. Replace `iot.t-mobile.nl` with the appropriate APN for your carrier, and `"ZTE_t_mobile"` with your desired connection name:
     ```
     sudo nmcli c add type gsm ifname '*' con-name "ZTE_t_mobile" apn iot.t-mobile.nl
     ```

5. **Establish the Connection:**
   - Use the following command to bring up the newly created connection:
     ```
     sudo nmcli connection up "ZTE_t_mobile"
     ```

6. **Set Autoconnect (Optional):**
   - If you want the modem to automatically connect when the system starts, you can enable autoconnect for the connection:
     ```
     sudo nmcli c modify "ZTE_t_mobile" connection.autoconnect yes
     ```

   Note: Depending on your carrier and network conditions, it may take some time (up to 12 minutes) for the modem to establish a connection. Be patient and wait for it to connect.

These steps should help you set up and use your ZTE MF667 LTE USB modem with your Wazigate device. Make sure to replace the placeholder values with the actual vendor and product IDs, APN, and connection name as needed for your specific configuration.
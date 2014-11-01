using System;
using System.IO.Ports;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows.Forms;

namespace RisemUSB
{
    public partial class RisemUSB : Form
    {
        TcpListener Connection = new TcpListener(IPAddress.Parse("127.0.0.1"), 2009);
        TcpClient Client;
        NetworkStream ClientNS;

        SerialPort USB = new SerialPort();

        string InputData = String.Empty;
        string[] SerialConfig = new String[6] { "07", "1", "0", "0", "0", "COM11" };
    
        public RisemUSB()
        {
            InitializeComponent();
        }

        private void RisemUSB_Load(object sender, EventArgs e)
        {
            Connection.Start();
            this.Hide();
            USB.DiscardNull = true;
            USB.NewLine = "\r\n";
        }

        private void Answer(string message, NetworkStream ns)
        {
            ASCIIEncoding asen = new ASCIIEncoding();
            byte[] msgBytes = asen.GetBytes(message + "\r\n"); //any message must be serialized (converted to byte array)
            ns.Write(msgBytes, 0, msgBytes.Length); //sending the message
        }

        private string[] ConvertSerial(string[] a)
        {
            string[] r = new String[6];
            r[5] = a[5];
            switch (a[0])
            {
                case "00":
                    r[0] = "300";
                    break;
                case "01":
                    r[0] = "600";
                    break;
                case "02":
                    r[0] = "1200";
                    break;
                case "03":
                    r[0] = "2400";
                    break;
                case "04":
                    r[0] = "4800";
                    break;
                case "05":
                    r[0] = "9600";
                    break;
                case "06":
                    r[0] = "14400";
                    break;
                case "07":
                    r[0] = "19200";
                    break;
                case "08":
                    r[0] = "38400";
                    break;
                case "09":
                    r[0] = "57600";
                    break;
                case "10":
                    r[0] = "115200";
                    break;
            }
            switch (a[1])
            {
                case "0":
                    r[1] = "7";
                    break;
                case "1":
                    r[1] = "8";
                    break;
            }
            switch (a[2])
            {
                case "0":
                    r[2] = "One";
                    break;
                case "1":
                    r[2] = "OnePointFive";
                    break;
                case "2":
                    r[2] = "Two";
                    break;
            }
            switch (a[3])
            {
                case "0":
                    r[3] = "None";
                    break;
                case "1":
                    r[3] = "Even";
                    break;
                case "2":
                    r[3] = "Mark";
                    break;
                case "3":
                    r[3] = "Odd";
                    break;
                case "4":
                    r[3] = "Space";
                    break;
            }
            switch (a[4])
            {
                case "0":
                    r[4] = "None";
                    break;
                case "1":
                    r[4] = "XOnXOff";
                    break;
                case "2":
                    r[4] = "RequestToSend";
                    break;
                case "3":
                    r[4] = "RequestToSendXOnXOff";
                    break;
            }
            return r;
        }

        private void Loop_Tick(object sender, EventArgs e)
        {
            if (USB.IsOpen && USB.BytesToRead > 0)
            {
                String RecievedData;
                RecievedData = USB.ReadExisting();
                if (!(RecievedData == ""))
                {
                    InputData += RecievedData;
                }
            }

            if (Connection.Pending())
            {
                Client = Connection.AcceptTcpClient();
                ClientNS = Client.GetStream();
            }

            if (Client != null && Client.Connected == true)
            {
                if (ClientNS != null && ClientNS.DataAvailable)
                {
                    ASCIIEncoding asen = new ASCIIEncoding();
                    byte[] msg = new byte[1024];
                    ClientNS.Read(msg, 0, msg.Length);
                    string lll = asen.GetString(msg);
                    char[] charsToTrim = { ' ', '\n', '\r' };
                    lll.Trim(charsToTrim);
                    string a = lll.Trim(charsToTrim).Substring(2, lll.Length - 2).Trim(charsToTrim).Normalize();
                    if (!(a.IndexOf('\n') + 1 <= 0))
                        a = a.Remove(a.IndexOf('\n') + 1).Trim(charsToTrim);
                    
                    switch (lll.Substring(0, 2))
                    {
                        case "01":
                            SerialConfig[5] = lll.Substring(2,6).Trim(charsToTrim);
                            Answer("01" + SerialConfig[5], ClientNS);
                            break;
                        case "02":
                            SerialConfig[0] = lll.Substring(2, 2);
                            break;
                        case "03":
                            SerialConfig[1] = lll.Substring(2, 1);
                            break;
                        case "04":
                            SerialConfig[2] = lll.Substring(2, 1);
                            break;
                        case "05":
                            SerialConfig[3] = lll.Substring(2, 1);
                            break;
                        case "06":
                            SerialConfig[4] = lll.Substring(2, 1);
                            break;
                        case "07":
                            if (!USB.IsOpen)
                            {
                                string[] pu = ConvertSerial(SerialConfig);
                                USB.PortName = Convert.ToString(pu[5]);
                                USB.BaudRate = Convert.ToInt32(pu[0]);
                                USB.DataBits = Convert.ToInt16(pu[1]);
                                USB.StopBits = (StopBits)Enum.Parse(typeof(StopBits), pu[2]);
                                USB.Handshake = (Handshake)Enum.Parse(typeof(Handshake), pu[4]);
                                USB.Parity = (Parity)Enum.Parse(typeof(Parity), pu[3]);
                                try
                                {
                                    USB.Open();
                                }
                                catch (UnauthorizedAccessException)
                                {
                                    Answer("31ERROR: Couldn't connect to port, currently in use by other application", ClientNS);
                                }
                                catch (ArgumentOutOfRangeException)
                                {
                                    Answer("31ERROR: Couldn't connect to port, one or more configurations are wrong", ClientNS);
                                }
                                catch (ArgumentException)
                                {
                                    Answer("31ERROR: The COM port name is wrong or inaccessible", ClientNS);
                                }
                                catch (InvalidOperationException)
                                {
                                    Answer("31ERROR: Already connected to this port", ClientNS);
                                }
                            }
                            break;
                        case "08":
                            if (USB.IsOpen)
                            {
                                USB.Close();
                                Answer("08CLOSED", ClientNS);
                            }
                            else
                            {
                                Answer("31ERROR: The port was already closed", ClientNS);
                            }
                            break;
                        case "09":
                            SerialConfig[0] = "07";
                            SerialConfig[1] = "1";
                            SerialConfig[2] = "0";
                            SerialConfig[3] = "0";
                            SerialConfig[4] = "0";
                            break;
                        case "10":
                            if (USB.IsOpen)
                            {
                                USB.WriteLine(a);
                                Answer("10" + a, ClientNS);
                            }
                            else
                            {
                                Answer("31ERROR: The port is closed", ClientNS);
                            }
                            break;
                        case "11":
                            string[] PortNames = null;
                            PortNames = SerialPort.GetPortNames();
                            if (PortNames != null && PortNames.Length > 0)
                            {
                                Answer("11" + String.Join(",", PortNames), ClientNS);
                            }
                            else
                            {
                                Answer("11", ClientNS);
                            }
                            break;
                        case "12":
                            Answer("12" + SerialConfig[0], ClientNS);
                            break;
                        case "13":
                            Answer("13" + SerialConfig[1], ClientNS);
                            break;
                        case "14":
                            Answer("14" + SerialConfig[2], ClientNS);
                            break;
                        case "15":
                            Answer("15" + SerialConfig[3], ClientNS);
                            break;
                        case "16":
                            Answer("16" + SerialConfig[4], ClientNS);
                            break;
                        case "17":
                            if (USB.IsOpen)
                                Answer("171", ClientNS);
                            else
                                Answer("170", ClientNS);
                            break;
                        case "18":
                            if (USB.IsOpen)
                            {
                                Answer("18" + Convert.ToString(USB.BytesToRead), ClientNS);
                            }
                            else
                            {
                                Answer("31ERROR: The port is currently closed", ClientNS);
                            }
                            break;
                        case "19":
                            Answer("19" + String.Join(",", SerialConfig), ClientNS);
                            break;
                        case "20":
                            if (USB.IsOpen)
                            {
                                if (USB.BytesToRead > 0)
                                {
                                    String RecievedData;
                                    RecievedData = USB.ReadExisting();
                                    if (!(RecievedData == ""))
                                    {
                                        InputData += RecievedData;
                                    }
                                }

                                if (InputData == null)
                                {
                                    Answer("20", ClientNS);
                                }
                                else
                                {
                                    Answer("20" + InputData, ClientNS);
                                    InputData = null;
                                }
                            }
                            else
                            {
                                Answer("20", ClientNS);
                            }
                            break;
                        case "30":
                            if (ClientNS != null && Client != null)
                            {
                                Answer("30BYEBYE", ClientNS);
                                ClientNS.Dispose();
                                Client.Close();
                            }
                            if (USB.IsOpen)
                                USB.Close();

                            Connection.Stop();
                            this.Dispose();
                            this.Close();
                            break;
                    }
                }
            }
        }

        private void RisemUSB_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (ClientNS != null && Client != null)
            {
                Answer("30BYEBYE", ClientNS);
                ClientNS.Dispose();
                Client.Close();
            }
            if (USB.IsOpen)
                USB.Close();

            Connection.Stop();

            Loop.Enabled = false;
            Loop.Stop();
            Loop.Dispose();
        }
    }
}

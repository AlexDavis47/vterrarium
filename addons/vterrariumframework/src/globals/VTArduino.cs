using Godot;
using System;
using System.IO.Ports;
using System.Linq;

public partial class VTArduino : Node
{
    [Export]
    public string PortName { get; set; } = ""; // Will be auto-detected

    [Export] 
    public int BaudRate { get; set; } = 9600;

    private SerialPort _serialPort;
    private bool _isConnected = false;
    private string _serialBuffer = "";
    
    // Store the raw value from port a0
    private int _rawValue = 0;

    public override void _Ready()
    {
        GD.Print("VTArduino: _Ready");
        DetectAndConnectToArduino();
    }

    public override void _Process(double delta)
    {
        // Read data from Arduino if connected
        if (IsConnected())
        {
            try
            {
                // Check if there's data available to read
                if (_serialPort.BytesToRead > 0)
                {
                    // Read available data
                    string data = _serialPort.ReadExisting();
                    _serialBuffer += data;

                    // Process complete lines
                    int newlineIndex;
                    while ((newlineIndex = _serialBuffer.IndexOf('\n')) != -1)
                    {
                        // Extract the line
                        string line = _serialBuffer.Substring(0, newlineIndex).Trim();
                        _serialBuffer = _serialBuffer.Substring(newlineIndex + 1);

                        // Process the data
                        ProcessArduinoData(line);
                    }
                }
            }
            catch (Exception e)
            {
                GD.PrintErr($"Error reading from Arduino: {e.Message}");
                DisconnectFromArduino();
            }
        }
    }

    private void ProcessArduinoData(string data)
    {
        // Simply parse the incoming data as an integer value
        if (int.TryParse(data, out int value))
        {
            _rawValue = value;
        }
    }

    public override void _ExitTree()
    {
        DisconnectFromArduino();
    }

    private void DetectAndConnectToArduino()
    {
        string[] ports = GetAvailablePorts();
        
        // Try to find Arduino port
        foreach (string port in ports)
        {
            try
            {
                // Try to connect to each port
                _serialPort = new SerialPort(port, BaudRate)
                {
                    DtrEnable = true,
                    ReadTimeout = 500,
                    WriteTimeout = 500
                };

                _serialPort.Open();
                System.Threading.Thread.Sleep(2000); // Give Arduino time to reset

                // Try reading from the port
                string response = _serialPort.ReadLine();
                if (!string.IsNullOrEmpty(response))
                {
                    // Found a responsive port
                    PortName = port;
                    _isConnected = true;
                    GD.Print($"VTArduino: Connected to Arduino on port {PortName}");
                    return;
                }

                // If no response, close and try next port
                _serialPort.Close();
                _serialPort.Dispose();
            }
            catch
            {
                // If connection fails, cleanup and continue to next port
                if (_serialPort != null)
                {
                    _serialPort.Close();
                    _serialPort.Dispose();
                }
            }
        }

        // If we get here, no Arduino was found
        GD.PrintErr("VTArduino: No Arduino found on any available port");
        _isConnected = false;
    }

    public void DisconnectFromArduino()
    {
        if (_serialPort != null && _serialPort.IsOpen)
        {
            _serialPort.Close();
            _serialPort.Dispose();
            _isConnected = false;
            GD.Print("VTArduino: Disconnected from Arduino");
        }
    }

    // Check if connected
    public bool IsConnected()
    {
        return _isConnected && _serialPort != null && _serialPort.IsOpen;
    }

    // Utility method to list all available serial ports
    public string[] GetAvailablePorts()
    {
        return SerialPort.GetPortNames();
    }
    
    // Get the raw value from the Arduino
    public int GetRawValue()
    {
        return _rawValue;
    }
}
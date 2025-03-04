using Godot;
using System;
using System.IO.Ports; // Requires System.IO.Ports NuGet package

public partial class NodeTest : Node
{
    [Export]
    public string PortName { get; set; } = "COM3"; // Default port (Windows). Use "/dev/ttyUSB0" for Linux or "/dev/cu.usbserial-XXXX" for macOS

    [Export]
    public int BaudRate { get; set; } = 9600;

    private SerialPort _serialPort;
    private bool _isConnected = false;
    private int _photodiodeValue = 0;
    private string _serialBuffer = "";

    // Add properties to track min/max values for calibration
    private int _minPhotodiodeValue = 1023; // Start with max possible value
    private int _maxPhotodiodeValue = 0;    // Start with min possible value

    public override void _Ready()
    {
        ConnectToArduino();
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

                        // Try to parse the photodiode value
                        if (int.TryParse(line, out int value))
                        {
                            _photodiodeValue = value;
                            
                            // Update min/max values for calibration
                            if (value < _minPhotodiodeValue) _minPhotodiodeValue = value;
                            if (value > _maxPhotodiodeValue) _maxPhotodiodeValue = value;
                        }
                    }
                }

                // Print the current photodiode value every frame
                GD.Print($"Photodiode Value: {_photodiodeValue} (Min: {_minPhotodiodeValue}, Max: {_maxPhotodiodeValue})");
            }
            catch (Exception e)
            {
                GD.PrintErr($"Error reading from Arduino: {e.Message}");
                DisconnectFromArduino();
            }
        }
    }

    public override void _ExitTree()
    {
        DisconnectFromArduino();
    }

    public void ConnectToArduino()
    {
        try
        {
            _serialPort = new SerialPort(PortName, BaudRate)
            {
                DtrEnable = true, // Data Terminal Ready - often needed for Arduino to reset properly
            };

            _serialPort.Open();
            _isConnected = true;
            GD.Print($"Connected to Arduino on port {PortName}");
        }
        catch (Exception e)
        {
            GD.PrintErr($"Failed to connect to Arduino: {e.Message}");
            _isConnected = false;
        }
    }

    public void DisconnectFromArduino()
    {
        if (_serialPort != null && _serialPort.IsOpen)
        {
            _serialPort.Close();
            _serialPort.Dispose();
            _isConnected = false;
            GD.Print("Disconnected from Arduino");
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
    
    // Get the current photodiode value
    public int GetPhotodiodeValue()
    {
        return _photodiodeValue;
    }
    
    // Get normalized photodiode value (0.0 to 1.0)
    public float GetNormalizedPhotodiodeValue()
    {
        if (_maxPhotodiodeValue == _minPhotodiodeValue)
            return 0.0f;
            
        return (float)(_photodiodeValue - _minPhotodiodeValue) / (_maxPhotodiodeValue - _minPhotodiodeValue);
    }
    
    // Reset min/max values for recalibration
    public void ResetCalibration()
    {
        _minPhotodiodeValue = 1023;
        _maxPhotodiodeValue = 0;
    }
}
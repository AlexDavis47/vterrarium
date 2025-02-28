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

    public override void _Ready()
    {
        ConnectToArduino();
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
}
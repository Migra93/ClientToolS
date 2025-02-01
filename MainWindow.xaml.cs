using System;
using System.Windows;
using System.Windows.Controls;
using ClientAnalyseTool.Views;

namespace ClientAnalyseTool
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            LoadUserInfo();
        }

        private void LoadUserInfo()
        {
            UserNameText.Text = Environment.UserName;
            HostNameText.Text = Environment.MachineName;
        }

        // Lädt das gewünschte Tool in den ToolContent-Bereich
        private void LoadTool(UserControl tool)
        {
            ToolContent.Content = tool;
        }

        private void LoadRegistryTool(object sender, RoutedEventArgs e)
        {
            LoadTool(new RegistryTool());
        }

        private void LoadTool(RegistryTool registryTool)
        {
            throw new NotImplementedException();
        }

        private void LoadNetworkTool(object sender, RoutedEventArgs e)
        {
            LoadTool(new NetworkTool());
        }

        private void LoadTool(NetworkTool networkTool)
        {
            throw new NotImplementedException();
        }

        private void LoadIntuneTool(object sender, RoutedEventArgs e)
        {
            LoadTool(new IntuneTool());
        }

        private void LoadTool(IntuneTool intuneTool)
        {
            throw new NotImplementedException();
        }
    }
}

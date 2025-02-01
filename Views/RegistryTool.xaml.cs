using System;
using System.Windows;
using System.Windows.Controls;

#if WINDOWS
using Microsoft.Win32;
#endif

namespace ClientAnalyseTool.Views
{
    public partial class RegistryTool : UserControl
    {
        public RegistryTool()
        {
            InitializeComponent();
        }

        // 🔍 Registry Suche
        private void SearchRegistry(object sender, RoutedEventArgs e)
        {
#if WINDOWS
            if (string.IsNullOrWhiteSpace(RegistrySearchBox.Text))
            {
                MessageBox.Show("Bitte einen Suchbegriff eingeben!", "Hinweis", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            RegistryResults.Items.Clear();
            SearchRegistryKeys(Registry.CurrentUser, RegistrySearchBox.Text);
#endif
        }

#if WINDOWS
        private void SearchRegistryKeys(RegistryKey rootKey, string searchTerm)
        {
            foreach (string subKeyName in rootKey.GetSubKeyNames())
            {
                using (RegistryKey? subKey = rootKey.OpenSubKey(subKeyName))
                {
                    if (subKey == null) continue;
                    RegistryResults.Items.Add($"Key gefunden: {subKey.Name}");
                }
            }
        }
#endif

        // 🗑️ Registry Schlüssel löschen
        private void DeleteRegistryKey(object sender, RoutedEventArgs e)
        {
#if WINDOWS
            if (RegistryResults.SelectedItem == null)
            {
                MessageBox.Show("Bitte einen Schlüssel auswählen!", "Fehler", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            string selectedKey = RegistryResults.SelectedItem.ToString()?.Replace("Key: ", "") ?? string.Empty;

            if (string.IsNullOrEmpty(selectedKey))
            {
                MessageBox.Show("Ungültiger Schlüssel!", "Fehler", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            try
            {
                Registry.CurrentUser.DeleteSubKeyTree(selectedKey);
                MessageBox.Show("Schlüssel erfolgreich gelöscht!", "Erfolg", MessageBoxButton.OK, MessageBoxImage.Information);
                RegistryResults.Items.Remove(RegistryResults.SelectedItem);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Fehler beim Löschen: {ex.Message}", "Fehler", MessageBoxButton.OK, MessageBoxImage.Error);
            }
#endif
        }

        // 📂 Backup der Registry
        private void BackupRegistryKey(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Backup-Funktion muss noch implementiert werden.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        // 🔄 Wiederherstellen eines Registry-Backups
        private void RestoreRegistryKey(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Restore-Funktion muss noch implementiert werden.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace Table
{
    /// <summary>
    /// Логика взаимодействия для Notification.xaml
    /// </summary>
    public partial class Notification : Window
    {
        private MainWindow mainWindow;
        public Notification(MainWindow mainWindow, string command)
        {
            InitializeComponent();
            this.mainWindow = mainWindow;
            placeNotification();
            NotificationLabel.Content = "Table goes " + command + "!";
        }

        private void placeNotification()
        {
            var desktopWorkingArea = System.Windows.Forms.Screen.PrimaryScreen.WorkingArea;
            this.Left = desktopWorkingArea.Right - this.Width;
            this.Top = desktopWorkingArea.Bottom - this.Height;
        }

        private void Accept_Button_Click(object sender, RoutedEventArgs e)
        {
            mainWindow.addActionDone("Accepted");
            this.Close();
        }

        private void Decline_Button_Click(object sender, RoutedEventArgs e)
        {
            mainWindow.addActionDone("Declined");
            mainWindow.setNotificationNotOpened();
            this.Close();
        }
    }
}

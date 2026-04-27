using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Management;
using System.Text;
using System.Windows.Forms;

namespace TwitchDropsMinerLauncher
{
    internal static class Program
    {
        private static readonly string[] AccountFolderNames = new string[]
        {
            "TwitchDropsMiner-dev",
            "TwitchDropsMiner-account2",
            "TwitchDropsMiner-account3",
            "TwitchDropsMiner-account4"
        };

        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var errors = new List<string>();

            string baseFolder = Path.GetDirectoryName(Application.ExecutablePath);

            foreach (string accountFolderName in AccountFolderNames)
            {
                string folder = Path.Combine(baseFolder, accountFolderName);
                string python = Path.Combine(folder, "env", "Scripts", "python.exe");
                string main = Path.Combine(folder, "main.py");

                if (!Directory.Exists(folder))
                {
                    errors.Add("Mappen findes ikke: " + folder);
                    continue;
                }

                if (!File.Exists(python))
                {
                    errors.Add("Python mangler: " + python);
                    continue;
                }

                if (!File.Exists(main))
                {
                    errors.Add("main.py mangler: " + main);
                    continue;
                }

                if (IsAlreadyRunning(folder))
                {
                    continue;
                }

                try
                {
                    var startInfo = new ProcessStartInfo();
                    startInfo.FileName = python;
                    startInfo.Arguments = "main.py";
                    startInfo.WorkingDirectory = folder;
                    startInfo.UseShellExecute = false;
                    startInfo.CreateNoWindow = true;
                    Process.Start(startInfo);
                }
                catch (Exception ex)
                {
                    errors.Add(folder + ": " + ex.Message);
                }
            }

            if (errors.Count > 0)
            {
                var message = new StringBuilder();
                message.AppendLine("Nogle TwitchDropsMiner-konti kunne ikke startes:");
                message.AppendLine();
                foreach (string error in errors)
                {
                    message.AppendLine("- " + error);
                }
                MessageBox.Show(message.ToString(), "TwitchDropsMiner Launcher", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static bool IsAlreadyRunning(string folder)
        {
            string normalizedFolder = folder.ToLowerInvariant();

            try
            {
                using (var searcher = new ManagementObjectSearcher(
                    "SELECT CommandLine FROM Win32_Process WHERE Name = 'python.exe' OR Name = 'pythonw.exe'"))
                {
                    foreach (ManagementObject process in searcher.Get())
                    {
                        object commandLineValue = process["CommandLine"];
                        if (commandLineValue == null)
                        {
                            continue;
                        }

                        string commandLine = commandLineValue.ToString().ToLowerInvariant();
                        if (commandLine.Contains(normalizedFolder))
                        {
                            return true;
                        }
                    }
                }
            }
            catch
            {
                return false;
            }

            return false;
        }
    }
}

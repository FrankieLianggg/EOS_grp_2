import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

public class Project2DemoUI extends JFrame {
    private final JTextField userAuthorizationKeyField = new JTextField(String.valueOf(DbConfig.DEFAULT_USER_AUTHORIZATION_KEY), 8);
    private final JButton loadStarSchemaButton = new JButton("Run Project2.LoadStarSchemaData");
    private final JButton showWorkflowStepsButton = new JButton("Run Process.usp_ShowWorkflowSteps");
    private final JButton clearButton = new JButton("Clear Results");
    private final JTable resultsTable = new JTable();
    private final JTextArea logArea = new JTextArea(8, 80);
    private final JLabel statusLabel = new JLabel("Ready");

    public Project2DemoUI() {
        super("Project 2 JDBC Demo");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout(10, 10));

        JPanel controls = new JPanel(new FlowLayout(FlowLayout.LEFT));
        controls.add(new JLabel("UserAuthorizationKey:"));
        controls.add(userAuthorizationKeyField);
        controls.add(loadStarSchemaButton);
        controls.add(showWorkflowStepsButton);
        controls.add(clearButton);

        resultsTable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
        JScrollPane tableScroll = new JScrollPane(resultsTable);
        tableScroll.setPreferredSize(new Dimension(1100, 420));

        logArea.setEditable(false);
        logArea.setLineWrap(true);
        logArea.setWrapStyleWord(true);
        JScrollPane logScroll = new JScrollPane(logArea);

        JPanel southPanel = new JPanel(new BorderLayout(5, 5));
        southPanel.add(statusLabel, BorderLayout.NORTH);
        southPanel.add(logScroll, BorderLayout.CENTER);

        add(controls, BorderLayout.NORTH);
        add(tableScroll, BorderLayout.CENTER);
        add(southPanel, BorderLayout.SOUTH);

        loadStarSchemaButton.addActionListener(e -> runLoadStarSchema());
        showWorkflowStepsButton.addActionListener(e -> runShowWorkflowSteps());
        clearButton.addActionListener(e -> clearResults());

        pack();
        setLocationRelativeTo(null);
    }

    private void runLoadStarSchema() {
        Integer userKey = parseUserAuthorizationKey();
        if (userKey == null) {
            return;
        }

        setBusy(true, "Running Project2.LoadStarSchemaData...");

        SwingWorker<Void, String> worker = new SwingWorker<>() {
            private long started;

            @Override
            protected Void doInBackground() throws Exception {
                started = System.currentTimeMillis();
                publish("Connecting to SQL Server...");
                try (Connection conn = openConnection();
                     CallableStatement cs = conn.prepareCall("{call Project2.LoadStarSchemaData(?)}")) {
                    cs.setInt(1, userKey);
                    publish("Executing Project2.LoadStarSchemaData(" + userKey + ")...");
                    cs.execute();
                    long elapsed = System.currentTimeMillis() - started;
                    publish("LoadStarSchemaData completed successfully in " + elapsed + " ms.");
                }
                return null;
            }

            @Override
            protected void process(java.util.List<String> chunks) {
                for (String line : chunks) {
                    appendLog(line);
                }
            }

            @Override
            protected void done() {
                try {
                    get();
                    statusLabel.setText("Load complete. You can now click Show Workflow Steps.");
                    appendLog("Tip: Run Process.usp_ShowWorkflowSteps next to display the workflow log in the JTable.");
                } catch (Exception ex) {
                    handleException("LoadStarSchemaData failed", ex);
                } finally {
                    setBusy(false, "Ready");
                }
            }
        };

        worker.execute();
    }

    private void runShowWorkflowSteps() {
        setBusy(true, "Running Process.usp_ShowWorkflowSteps...");

        SwingWorker<DefaultTableModel, String> worker = new SwingWorker<>() {
            @Override
            protected DefaultTableModel doInBackground() throws Exception {
                publish("Connecting to SQL Server...");
                try (Connection conn = openConnection();
                     CallableStatement cs = conn.prepareCall("{call Process.usp_ShowWorkflowSteps}")) {
                    publish("Executing Process.usp_ShowWorkflowSteps...");
                    try (ResultSet rs = cs.executeQuery()) {
                        return buildTableModel(rs);
                    }
                }
            }

            @Override
            protected void process(java.util.List<String> chunks) {
                for (String line : chunks) {
                    appendLog(line);
                }
            }

            @Override
            protected void done() {
                try {
                    DefaultTableModel model = get();
                    resultsTable.setModel(model);
                    autoResizeColumns(resultsTable);
                    statusLabel.setText("Workflow steps loaded into JTable. Rows: " + model.getRowCount());
                    appendLog("Workflow steps displayed successfully.");
                } catch (Exception ex) {
                    handleException("usp_ShowWorkflowSteps failed", ex);
                } finally {
                    setBusy(false, "Ready");
                }
            }
        };

        worker.execute();
    }

    private Integer parseUserAuthorizationKey() {
        String text = userAuthorizationKeyField.getText().trim();
        try {
            int value = Integer.parseInt(text);
            if (value <= 0) {
                throw new NumberFormatException("must be positive");
            }
            return value;
        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this,
                    "Enter a valid positive integer for UserAuthorizationKey.",
                    "Invalid Input",
                    JOptionPane.ERROR_MESSAGE);
            return null;
        }
    }

    private Connection openConnection() throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(DbConfig.jdbcUrl(), DbConfig.USER, DbConfig.PASSWORD);
    }

    private static DefaultTableModel buildTableModel(ResultSet rs) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();

        Vector<String> columnNames = new Vector<>();
        for (int i = 1; i <= columnCount; i++) {
            columnNames.add(meta.getColumnLabel(i));
        }

        Vector<Vector<Object>> rows = new Vector<>();
        while (rs.next()) {
            Vector<Object> row = new Vector<>();
            for (int i = 1; i <= columnCount; i++) {
                row.add(rs.getObject(i));
            }
            rows.add(row);
        }

        return new DefaultTableModel(rows, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
    }

    private static void autoResizeColumns(JTable table) {
        for (int col = 0; col < table.getColumnCount(); col++) {
            int width = 100;
            for (int row = 0; row < table.getRowCount(); row++) {
                Object value = table.getValueAt(row, col);
                if (value != null) {
                    width = Math.max(width, value.toString().length() * 7 + 24);
                }
            }
            width = Math.min(width, 320);
            table.getColumnModel().getColumn(col).setPreferredWidth(width);
        }
    }

    private void clearResults() {
        resultsTable.setModel(new DefaultTableModel());
        logArea.setText("");
        statusLabel.setText("Ready");
    }

    private void appendLog(String message) {
        logArea.append(message + System.lineSeparator());
        logArea.setCaretPosition(logArea.getDocument().getLength());
    }

    private void setBusy(boolean busy, String statusText) {
        loadStarSchemaButton.setEnabled(!busy);
        showWorkflowStepsButton.setEnabled(!busy);
        clearButton.setEnabled(!busy);
        userAuthorizationKeyField.setEnabled(!busy);
        statusLabel.setText(statusText);
        setCursor(busy ? Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR) : Cursor.getDefaultCursor());
    }

    private void handleException(String context, Exception ex) {
        StringBuilder sb = new StringBuilder();
        sb.append(context).append(": ").append(ex.getMessage());
        Throwable cause = ex.getCause();
        while (cause != null) {
            sb.append(System.lineSeparator()).append("Caused by: ").append(cause.getMessage());
            cause = cause.getCause();
        }
        appendLog(sb.toString());
        statusLabel.setText(context + ". See log.");
        JOptionPane.showMessageDialog(this, sb.toString(), "Database Error", JOptionPane.ERROR_MESSAGE);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new Project2DemoUI().setVisible(true));
    }
}

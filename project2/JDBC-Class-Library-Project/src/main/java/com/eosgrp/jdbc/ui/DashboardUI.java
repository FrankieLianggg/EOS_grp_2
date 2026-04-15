package com.eosgrp.jdbc.ui;

import com.eosgrp.jdbc.factory.DaoFactory;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;
import javax.swing.table.DefaultTableModel;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.Font;
import java.util.List;
import java.util.Map;
import java.util.Vector;

public class DashboardUI extends JFrame {

    private final JTextArea statusArea;
    private final JTable resultTable;
    private final DefaultTableModel tableModel;

    public DashboardUI() {
        setTitle("JDBC Class Library Dashboard");
        setSize(900, 600);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout(10, 10));

        JLabel titleLabel = new JLabel("JDBC Class Library Dashboard", SwingConstants.CENTER);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 22));
        add(titleLabel, BorderLayout.NORTH);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 15, 10));
        JButton loadCustomersButton = new JButton("Load Customers");
        JButton loadOrdersButton = new JButton("Load Orders");
        JButton loadProductsButton = new JButton("Load Products");
        JButton clearButton = new JButton("Clear");

        buttonPanel.add(loadCustomersButton);
        buttonPanel.add(loadOrdersButton);
        buttonPanel.add(loadProductsButton);
        buttonPanel.add(clearButton);
        add(buttonPanel, BorderLayout.SOUTH);

        tableModel = new DefaultTableModel();
        resultTable = new JTable(tableModel);
        JScrollPane tableScrollPane = new JScrollPane(resultTable);

        statusArea = new JTextArea(6, 30);
        statusArea.setEditable(false);
        statusArea.setLineWrap(true);
        statusArea.setWrapStyleWord(true);
        JScrollPane statusScrollPane = new JScrollPane(statusArea);

        JSplitPane splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, tableScrollPane, statusScrollPane);
        splitPane.setDividerLocation(400);
        add(splitPane, BorderLayout.CENTER);

        loadCustomersButton.addActionListener(e -> loadData("Customers", DaoFactory.getCustomerDao().getAllCustomers()));
        loadOrdersButton.addActionListener(e -> loadData("Orders", DaoFactory.getOrderDao().getAllOrders()));
        loadProductsButton.addActionListener(e -> loadData("Products", DaoFactory.getProductDao().getAllProducts()));
        clearButton.addActionListener(e -> clearDisplay());
    }

    private void loadData(String label, List<Map<String, Object>> data) {
        displayResults(data);
        statusArea.setText(label + " loaded. Rows returned: " + (data == null ? 0 : data.size()));
    }

    private void clearDisplay() {
        tableModel.setRowCount(0);
        tableModel.setColumnCount(0);
        statusArea.setText("Display cleared.");
    }

    private void displayResults(List<Map<String, Object>> results) {
        tableModel.setRowCount(0);
        tableModel.setColumnCount(0);

        if (results == null || results.isEmpty()) {
            statusArea.setText("No data returned.");
            return;
        }

        Map<String, Object> firstRow = results.get(0);
        Vector<String> columnNames = new Vector<>(firstRow.keySet());
        tableModel.setColumnIdentifiers(columnNames);

        for (Map<String, Object> row : results) {
            Vector<Object> rowData = new Vector<>();
            for (String column : columnNames) {
                rowData.add(row.get(column));
            }
            tableModel.addRow(rowData);
        }
    }
}

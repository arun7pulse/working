const csvFileInput = document.getElementById("csvFile");
const statusText = document.getElementById("status");
const xColumnSelect = document.getElementById("xColumn");
const yColumnSelect = document.getElementById("yColumn");
const chartTypeSelect = document.getElementById("chartType");
const renderChartButton = document.getElementById("renderChart");
const tableContainer = document.getElementById("tableContainer");
const chartCanvas = document.getElementById("chartCanvas");

const MAX_PREVIEW_ROWS = 100;

let rows = [];
let chart;

csvFileInput.addEventListener("change", async (event) => {
  const file = event.target.files[0];
  if (!file) {
    return;
  }

  const text = await file.text();
  const parsedResult = parseCsv(text);
  if (parsedResult.error) {
    statusText.textContent = parsedResult.error;
    return;
  }

  rows = parsedResult.data;

  if (!rows.length) {
    statusText.textContent = "No rows found in this CSV.";
    return;
  }

  const headers = Object.keys(rows[0]);
  const numericHeaders = headers.filter((header) => {
    const nonEmptyValues = rows.map((row) => row[header]).filter((value) => value !== "");
    return nonEmptyValues.length > 0 && nonEmptyValues.every((value) => !Number.isNaN(Number(value)));
  });

  populateSelect(xColumnSelect, headers);
  populateSelect(yColumnSelect, numericHeaders);

  xColumnSelect.disabled = false;
  yColumnSelect.disabled = numericHeaders.length === 0;
  chartTypeSelect.disabled = numericHeaders.length === 0;
  renderChartButton.disabled = numericHeaders.length === 0;

  if (!numericHeaders.length) {
    statusText.textContent = "CSV loaded. No numeric columns available for charting.";
  } else {
    statusText.textContent = `Loaded ${rows.length} row(s).`;
  }

  renderTable(rows);
});

renderChartButton.addEventListener("click", () => {
  const xKey = xColumnSelect.value;
  const yKey = yColumnSelect.value;
  const chartType = chartTypeSelect.value;

  if (!xKey || !yKey) {
    return;
  }

  const labels = rows.map((row) => row[xKey]);
  const values = rows.map((row) => (row[yKey] === "" ? null : Number(row[yKey])));

  if (chart) {
    chart.destroy();
  }

  chart = new Chart(chartCanvas, {
    type: chartType,
    data: {
      labels,
      datasets: [
        {
          label: yKey,
          data: values,
          borderColor: "#1162ff",
          backgroundColor: "rgba(17, 98, 255, 0.35)",
          fill: chartType !== "line",
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
    },
  });
});

function parseCsv(text) {
  const parsed = Papa.parse(text, {
    header: true,
    skipEmptyLines: true,
  });

  if (parsed.errors.length) {
    return { data: [], error: "Could not parse CSV. Please verify the file format." };
  }

  const data = parsed.data.map((row) =>
    Object.entries(row).reduce((acc, [key, value]) => {
      acc[key] = value == null ? "" : String(value).trim();
      return acc;
    }, {})
  );

  return { data, error: "" };
}

function populateSelect(selectElement, options) {
  selectElement.innerHTML = "";
  options.forEach((option) => {
    const item = document.createElement("option");
    item.value = option;
    item.textContent = option;
    selectElement.appendChild(item);
  });
}

function renderTable(data) {
  const headers = Object.keys(data[0] || {});
  if (!headers.length) {
    tableContainer.innerHTML = "<p>No data to preview.</p>";
    return;
  }

  const table = document.createElement("table");
  const thead = document.createElement("thead");
  const tbody = document.createElement("tbody");
  const headerRow = document.createElement("tr");

  headers.forEach((header) => {
    const th = document.createElement("th");
    th.textContent = header;
    headerRow.appendChild(th);
  });
  thead.appendChild(headerRow);

  data.slice(0, MAX_PREVIEW_ROWS).forEach((row) => {
    const tr = document.createElement("tr");
    headers.forEach((header) => {
      const td = document.createElement("td");
      td.textContent = row[header];
      tr.appendChild(td);
    });
    tbody.appendChild(tr);
  });

  table.appendChild(thead);
  table.appendChild(tbody);

  tableContainer.innerHTML = "";
  tableContainer.appendChild(table);
}

// _static/save_cell.js
// Add ONE "Download code" button per code cell container,
// and grab the live edited content (CodeMirror/textarea) if present.

window.addEventListener("DOMContentLoaded", function () {
  console.log("save_cell.js: initializing");

  // Helper: Retrieve CURRENT code (CodeMirror, textarea, or fallback <pre>)
  function getCurrentCode(container) {
    // 1. CodeMirror
    try {
      var cmElem = container.querySelector(".CodeMirror");
      if (cmElem && cmElem.CodeMirror && typeof cmElem.CodeMirror.getValue === "function") {
        return cmElem.CodeMirror.getValue();
      }
    } catch (e) {
      console.warn("save_cell.js: CodeMirror check failed:", e);
    }

    // 2. textarea
    try {
      var ta = container.querySelector("textarea");
      if (ta && typeof ta.value === "string") {
        return ta.value;
      }
    } catch (e2) {
      console.warn("save_cell.js: textarea check failed:", e2);
    }

    // 3. Fallback: first <pre> inside the container
    try {
      var pre = container.querySelector("pre");
      if (pre) {
        return (pre.innerText || pre.textContent || "").trim();
      }
    } catch (e3) {
      console.warn("save_cell.js: pre fallback failed:", e3);
    }

    return "";
  }

  // Start from all <pre> blocks
  var pres = document.querySelectorAll("pre");
  console.log("save_cell.js: found " + pres.length + " <pre> blocks");

  if (!pres.length) {
    console.warn("save_cell.js: no <pre> elements found.");
    return;
  }

  // Use a WeakSet to ensure we only add ONE button per container
  var seenContainers = new WeakSet();
  var cellIndex = 0;

  pres.forEach(function (pre) {
    // Try to locate a higher-level "cell container"
    var container =
      pre.closest(".thebe-cell, .thebelab-cell, .cell, .live-code") ||
      pre.parentElement ||
      pre;

    if (!container || seenContainers.has(container)) {
      // Either no sensible container or we've already added a button here
      return;
    }
    seenContainers.add(container);

    // Create the UVU-green download button (styled via save_cell.css)
    var button = document.createElement("button");
    button.type = "button";
    button.textContent = "Download code (cell " + cellIndex + ")";
    button.classList.add("download-code-btn");

    // Click handler for this container
    (function (thisIndex, thisContainer) {
      button.addEventListener("click", function () {
        try {
          var code = getCurrentCode(thisContainer);

          if (!code) {
            var proceed = window.confirm(
              "This code block appears to be empty. Download an empty file anyway?"
            );
            if (!proceed) {
              return;
            }
          }

          var baseName = document.title || "code_cell";
          baseName = baseName
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, "_")
            .replace(/^_+|_+$/g, "");

          var filename = baseName + "_cell_" + thisIndex + ".py";

          var blob = new Blob([code], { type: "text/x-python" });
          var url = URL.createObjectURL(blob);

          var link = document.createElement("a");
          link.href = url;
          link.download = filename;

          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);

          URL.revokeObjectURL(url);

          console.log("save_cell.js: downloaded " + filename);
        } catch (err) {
          console.error("save_cell.js: error downloading cell", thisIndex, err);
          window.alert(
            "Something went wrong while trying to download this code block."
          );
        }
      });
    })(cellIndex, container);

    // Place button at the end of the container (below code + output)
    container.insertAdjacentElement("beforeend", button);

    cellIndex += 1;
  });

  console.log("save_cell.js: created " + cellIndex + " download buttons.");
});
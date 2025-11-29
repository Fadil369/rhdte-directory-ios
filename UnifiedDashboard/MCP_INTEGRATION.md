# BrainSAIT MCP Server Integration

## ✅ Integration Complete!

The **Model Context Protocol (MCP) Server** from BrainSAIT has been successfully integrated into your Unified Dashboard.

---

## 🎯 What Was Added

### New MCP Dashboard Section
- **10 Advanced AI Tools** for file processing, healthcare, compliance, and development
- **Real-time server status** monitoring
- **Interactive tool execution** interface
- **Knowledge base integration** for codebase querying

### Tool Categories

#### 1. **File Processing**
- `upload_file`: Upload and process PDF, DOCX, medical documents
- Extracts diagnoses, medications, procedures
- PHI detection and HIPAA compliance

#### 2. **Knowledge Base**
- `knowledge_base`: Query indexed codebase and documentation
- RAG (Retrieval-Augmented Generation)
- FHIR patterns, NPHIES examples, UI components

#### 3. **Healthcare Tools**
- `fhir_validator`: Validate FHIR R4 with Saudi/NPHIES profiles
- `medical_coder`: ICD-10, CPT, SNOMED with Arabic support
- `hipaa_guardian`: PHI detection and redaction

#### 4. **Development Tools**
- `code_generator`: Generate Python, TypeScript, Swift code
- `ui_tester`: Computer-use for UI testing
- `batch_processor`: Quality scan, security audit, test generation

#### 5. **AI & Automation**
- `agent_memory`: Persistent memory for patterns
- `web_fetcher`: Real-time documentation fetching

---

## 📁 Files Added

```
UnifiedDashboard/
├── Sources/UnifiedDashboard/
│   ├── MCP/
│   │   └── MCPServerClient.swift          # MCP server client
│   └── Views/MCP/
│       └── MCPDashboardView.swift         # MCP dashboard UI
└── MCP_INTEGRATION.md                      # This file
```

---

## 🚀 Setup Instructions

### 1. Install Python MCP Server

```bash
# Create directory
mkdir -p ~/brainsait-mcp

# Install dependencies
pip3 install \
  mcp \
  anthropic \
  fhir.resources \
  fastapi \
  uvicorn

# Download server script
curl -o ~/brainsait-mcp/server.py \
  https://raw.githubusercontent.com/brainsait/mcp-tools/main/server.py

# Make executable
chmod +x ~/brainsait-mcp/server.py
```

### 2. Configure Environment

```bash
# Create .env file
cat > ~/brainsait-mcp/.env << 'ENV'
ANTHROPIC_API_KEY=sk-ant-your-key-here
OPENAI_API_KEY=sk-your-key-here
BRAINSAIT_KB_PATH=~/brainsait-mcp/knowledge-base
BRAINSAIT_WORKSPACE=~/BrainSAIT
ENV

# Create directories
mkdir -p ~/brainsait-mcp/{knowledge-base,uploads,memory,logs}
```

### 3. Test MCP Server

```bash
# Start server
cd ~/brainsait-mcp
python3 server.py

# Test in another terminal
curl http://localhost:8000/health
```

### 4. Run Unified Dashboard

```bash
cd ~/UnifiedDashboard
./run.sh
```

Navigate to **MCP Server** in the sidebar to see the integration!

---

## 🎨 UI Features

### Server Status Badge
- 🟢 **Green**: Connected
- 🟠 **Orange**: Connecting...
- ⚪ **Gray**: Disconnected
- 🔴 **Red**: Error

### Tool Categories with Icons
- 📄 **File Processing** (Blue)
- 🧠 **Knowledge Base** (Purple)
- ⚙️ **Automation** (Orange)
- 🏥 **Healthcare** (Red)
- ✅ **Compliance** (Green)
- ✨ **AI & Memory** (Pink)
- 💻 **Development** (Indigo)
- 🧪 **Testing** (Teal)
- 🔗 **Integration** (Yellow)

### Interactive Tool Execution
1. Click any tool card
2. Enter input (JSON, text, code)
3. Click "Execute Tool"
4. View results in monospaced output

---

## 💡 Usage Examples

### Example 1: Upload Medical Document

**Input:**
```json
{
  "file_path": "~/Documents/patient_record.pdf",
  "target": "claude",
  "process_type": "extract"
}
```

**Output:**
```
✅ File prepared for Claude upload:
- File: patient_record.pdf
- Type: application/pdf
- Size: 45,231 bytes
- Extracted: 3 diagnoses, 2 medications, 1 procedure
```

### Example 2: Validate FHIR Resource

**Input:**
```json
{
  "resourceType": "Patient",
  "name": [{"family": "الفاضل", "given": ["محمد"]}],
  "identifier": [{
    "system": "http://nphies.sa/identifier/national-id",
    "value": "1234567890"
  }]
}
```

**Output:**
```
✅ Valid FHIR Resource
- Profile: Saudi
- Arabic name: Supported
- NPHIES identifiers: Present
- Warnings: 0
```

### Example 3: Check HIPAA Compliance

**Input:**
```python
def process_patient(data):
    print(f"Processing: {data['ssn']}")  # PHI exposed!
    db.save(data)
```

**Output:**
```
❌ HIPAA Violations Found:
- PHI exposed in logging (line 2)
- Unencrypted database storage (line 3)
- Missing audit logging
Recommendations: Redact PHI, encrypt data, add audit trail
```

### Example 4: Generate Code

**Input:**
```
Create a FastAPI endpoint for FHIR Patient registration with:
- Saudi national ID validation
- Bilingual support (AR/EN)
- HIPAA audit logging
```

**Output:**
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class PatientRequest(BaseModel):
    given_name: str
    family_name: str
    national_id: str
    
@app.post("/patients")
async def create_patient(patient: PatientRequest):
    # Validate Saudi national ID
    if not validate_saudi_id(patient.national_id):
        raise HTTPException(400, "Invalid national ID")
    
    # Create FHIR resource
    fhir_patient = build_fhir_patient(patient)
    
    # Audit log
    audit_log.info(f"Patient created: {patient.national_id}")
    
    return {"id": fhir_patient["id"]}
```

---

## 🔧 Advanced Configuration

### Custom Server Path

Edit `MCPServerClient.swift`:

```swift
init(serverPath: String = "/custom/path/to/server.py") {
    self.serverPath = serverPath
}
```

### Add Custom Tools

Add to `loadAvailableTools()`:

```swift
MCPTool(
    name: "custom_tool",
    description: "Your custom tool description",
    category: .development
)
```

### Connect to Remote MCP Server

```swift
// Replace local process with HTTP client
func executeTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult {
    let url = URL(string: "https://your-mcp-server.com/tools/\(name)")!
    // Make HTTP request...
}
```

---

## 📊 Integration Architecture

```
┌─────────────────────────────────────────┐
│      UnifiedDashboard (SwiftUI)         │
│  ┌────────────────────────────────────┐ │
│  │    MCP Dashboard View              │ │
│  │    - Server controls               │ │
│  │    - Tool catalog                  │ │
│  │    - Interactive execution         │ │
│  └────────────────────────────────────┘ │
└─────────────────┬───────────────────────┘
                  │ Swift Process API
                  ▼
┌─────────────────────────────────────────┐
│    Python MCP Server (Local)            │
│  ┌────────────────────────────────────┐ │
│  │  10 Tools:                         │ │
│  │  - upload_file                     │ │
│  │  - knowledge_base                  │ │
│  │  - fhir_validator                  │ │
│  │  - hipaa_guardian                  │ │
│  │  - medical_coder                   │ │
│  │  - code_generator                  │ │
│  │  - batch_processor                 │ │
│  │  - agent_memory                    │ │
│  │  - ui_tester                       │ │
│  │  - web_fetcher                     │ │
│  └────────────────────────────────────┘ │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
  ┌───────────┐     ┌──────────────┐
  │ Anthropic │     │  Knowledge   │
  │   API     │     │     Base     │
  │  (Claude) │     │  (Indexed)   │
  └───────────┘     └──────────────┘
```

---

## 🎁 Benefits

### 1. **File Upload to Claude**
- Upload medical documents, code files, diagrams
- Extract structured data automatically
- Process with Claude's vision and analysis

### 2. **Knowledge Base Query**
- RAG over entire BrainSAIT codebase
- Find FHIR patterns, UI components, examples
- Semantic search with high accuracy

### 3. **Healthcare Compliance**
- Automatic HIPAA compliance checking
- FHIR validation with Saudi profiles
- Medical coding with Arabic support

### 4. **Code Generation**
- Generate Python, TypeScript, Swift
- Include tests, documentation, type hints
- Follow BrainSAIT patterns and standards

### 5. **Batch Processing**
- Scan entire directories
- Quality analysis, security audits
- Generate missing tests and docs

---

## 🚧 Troubleshooting

### Server Won't Start
```bash
# Check Python version
python3 --version  # Should be 3.9+

# Check dependencies
pip3 list | grep mcp

# Check server script
ls -l ~/brainsait-mcp/server.py
```

### Tools Not Loading
```bash
# Check server logs
tail -f ~/brainsait-mcp/logs/server.log

# Restart server
pkill -f server.py
python3 ~/brainsait-mcp/server.py
```

### Connection Issues
```swift
// Check server path in MCPServerClient.swift
print("Server path: \(serverPath)")

// Verify process is running
ps aux | grep server.py
```

---

## 📚 Resources

### Documentation
- [MCP Protocol](https://docs.claude.com/en/docs/agents-and-tools)
- [Anthropic Skills](https://github.com/anthropics/skills)
- [BrainSAIT MCP Tools](https://github.com/brainsait/mcp-tools)

### Examples
- `~/brainsait-mcp/examples/` - Sample use cases
- `~/brainsait-mcp/tests/` - Test suite
- `~/brainsait-mcp/skills/` - Agent skills library

### Support
- GitHub Issues: brainsait/mcp-tools
- Discord: discord.gg/brainsait
- Email: mcp-support@brainsait.com

---

## ✨ Next Steps

1. ✅ **Install Python MCP Server** (see Setup Instructions)
2. ✅ **Index your codebase** into knowledge base
3. ✅ **Test file upload** with a sample document
4. ✅ **Try FHIR validation** with Saudi profiles
5. ✅ **Generate code** for a new feature
6. ✅ **Run batch processing** on your project

---

**Built with ❤️ by BrainSAIT - Advancing Healthcare AI** 🏥🤖

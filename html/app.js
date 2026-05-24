const messagesContainer = document.getElementById('messages-container');
const inputContainer = document.getElementById('input-container');
const chatInput = document.getElementById('chat-input');
const prefixSpan = document.querySelector('.prefix');

let isChatOpen = false;
let messageTimeout = 10000; // Mesajların ekranda kalma süresi (ms)

// Message History
let messageHistory = [];
let historyIndex = -1;

// Command Suggestions
const suggestionsContainer = document.getElementById('suggestions-container');
let commands = [];

window.addEventListener('message', function(event) {
    const item = event.data;

    if (item.type === 'ON_OPEN') {
        openChat();
    } else if (item.type === 'ON_MESSAGE') {
        addMessage(item.message);
    } else if (item.type === 'LOAD_COMMANDS') {
        commands = item.commands;
    }
});

function openChat() {
    isChatOpen = true;
    document.querySelector('.chat-container').classList.add('active');
    inputContainer.style.display = 'block';
    chatInput.value = '';
    chatInput.focus();
    prefixSpan.textContent = '>';
    historyIndex = messageHistory.length;
    hideSuggestions();
}

function closeChat() {
    isChatOpen = false;
    document.querySelector('.chat-container').classList.remove('active');
    inputContainer.style.display = 'none';
    chatInput.value = '';
    chatInput.blur();
    hideSuggestions();
    fetch(`https://${GetParentResourceName()}/closeChat`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function addMessage(msg) {
    const msgElement = document.createElement('div');
    msgElement.classList.add('message');
    
    if (msg.templateId) {
        msgElement.classList.add(`msg-${msg.templateId}`);
    } else {
        msgElement.classList.add('msg-say'); // Default
    }

    let innerHTML = '';
    
    // Yazar varsa (Author)
    if (msg.author) {
        innerHTML += `<span class="msg-author">${msg.author}:</span> `;
    }
    
    // Mesaj içeriği
    if (msg.text) {
        innerHTML += `<span class="msg-text">${escapeHTML(msg.text)}</span>`;
    }

    msgElement.innerHTML = innerHTML;
    messagesContainer.appendChild(msgElement);
    
    // Otomatik aşağı kaydır
    messagesContainer.scrollTop = messagesContainer.scrollHeight;

    // Belirli bir süre sonra mesajı gizle (opacity ile)
    setTimeout(() => {
        msgElement.classList.add('hidden');
    }, messageTimeout);
    
    // Mesaj sayısını sınırla (Sürekli DOM büyümesini engelle)
    if (messagesContainer.children.length > 100) {
        messagesContainer.removeChild(messagesContainer.firstChild);
    }
}

// Güvenlik için HTML taglarını engelleme
function escapeHTML(str) {
    return str.replace(/[&<>'"]/g, 
        tag => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            "'": '&#39;',
            '"': '&quot;'
        }[tag] || tag)
    );
}

// Suggestions Logic
function showSuggestions(filteredCommands) {
    suggestionsContainer.innerHTML = '';
    if (filteredCommands.length === 0) {
        hideSuggestions();
        return;
    }
    
    filteredCommands.forEach(cmdObj => {
        const item = document.createElement('div');
        item.classList.add('suggestion-item');
        item.innerHTML = `<span class="suggestion-cmd">${cmdObj.cmd}</span><span class="suggestion-desc">${cmdObj.desc}</span>`;
        item.onclick = () => {
            chatInput.value = cmdObj.cmd + ' ';
            chatInput.focus();
            hideSuggestions();
        };
        suggestionsContainer.appendChild(item);
    });
    
    suggestionsContainer.style.display = 'block';
}

function hideSuggestions() {
    suggestionsContainer.style.display = 'none';
    suggestionsContainer.innerHTML = '';
}

chatInput.addEventListener('input', function(e) {
    const val = e.target.value;
    if (val.startsWith('/')) {
        const search = val.toLowerCase();
        const filtered = commands.filter(c => c.cmd.startsWith(search));
        showSuggestions(filtered);
    } else {
        hideSuggestions();
    }
});

// Input işlemleri (Enter, ESC, ArrowUp, ArrowDown)
document.addEventListener('keydown', function(event) {
    if (!isChatOpen) return;

    if (event.key === 'Enter') {
        const message = chatInput.value.trim();
        if (message.length > 0) {
            // Add to history
            if (messageHistory[messageHistory.length - 1] !== message) {
                messageHistory.push(message);
                if (messageHistory.length > 50) messageHistory.shift(); // Keep max 50
            }
            
            fetch(`https://${GetParentResourceName()}/sendMessage`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ message: message })
            });
        }
        closeChat();
    } else if (event.key === 'Escape') {
        closeChat();
    } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        if (historyIndex > 0) {
            historyIndex--;
            chatInput.value = messageHistory[historyIndex];
            hideSuggestions();
        }
    } else if (event.key === 'ArrowDown') {
        event.preventDefault();
        if (historyIndex < messageHistory.length - 1) {
            historyIndex++;
            chatInput.value = messageHistory[historyIndex];
        } else {
            historyIndex = messageHistory.length;
            chatInput.value = '';
        }
        hideSuggestions();
    }
});

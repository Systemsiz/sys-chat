const messagesContainer = document.getElementById('messages-container');
const inputContainer = document.getElementById('input-container');
const chatInput = document.getElementById('chat-input');
const prefixSpan = document.querySelector('.prefix');

let isChatOpen = false;
let messageTimeout = 10000; // Mesajların ekranda kalma süresi (ms)

window.addEventListener('message', function(event) {
    const item = event.data;

    if (item.type === 'ON_OPEN') {
        openChat();
    } else if (item.type === 'ON_MESSAGE') {
        addMessage(item.message);
    }
});

function openChat() {
    isChatOpen = true;
    inputContainer.style.display = 'block';
    chatInput.value = '';
    chatInput.focus();
    prefixSpan.textContent = '>';
}

function closeChat() {
    isChatOpen = false;
    inputContainer.style.display = 'none';
    chatInput.value = '';
    chatInput.blur();
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
        msgElement.classList.add('msg-ooc'); // Default
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
        // İsteğe bağlı olarak DOM'dan tamamen temizlenebilir
        setTimeout(() => {
            if(messagesContainer.contains(msgElement)) {
                msgElement.remove();
            }
        }, 500); // fade-out süresi
    }, messageTimeout);
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

// Input işlemleri (Enter ve ESC)
document.addEventListener('keydown', function(event) {
    if (!isChatOpen) return;

    if (event.key === 'Enter') {
        const message = chatInput.value.trim();
        if (message.length > 0) {
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
    }
});

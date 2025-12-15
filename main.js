// Configuration
const NOTIFICATION_EMAIL = 'dmvanmeenen@gmail.com';
const PAGE_VIEW_ENDPOINT = 'https://api.counterapi.dev/v1/hyperwave/landing/up';

// Store reference to the triggering button for focus management
let triggeringButton = null;

function openWaitlistModal() {
    const modal = document.getElementById('waitlistModal');
    modal.classList.add('active');
    document.getElementById('email').focus();
}

function closeWaitlistModal() {
    const modal = document.getElementById('waitlistModal');
    modal.classList.remove('active');

    document.getElementById('formContent').style.display = 'block';
    document.getElementById('successContent').style.display = 'none';
    document.getElementById('waitlistForm').reset();
    document.getElementById('email').classList.remove('error');
    document.getElementById('emailError').classList.remove('active');

    if (triggeringButton) {
        triggeringButton.focus();
        triggeringButton = null;
    }
}

function submitWaitlist(event) {
    event.preventDefault();

    const emailInput = document.getElementById('email');
    const emailError = document.getElementById('emailError');
    const email = emailInput.value.trim();

    if (!emailInput.validity.valid) {
        emailInput.classList.add('error');
        emailError.classList.add('active');
        return;
    }

    emailInput.classList.remove('error');
    emailError.classList.remove('active');

    const subject = encodeURIComponent('New HyperWave Waitlist Signup');
    const body = encodeURIComponent('New waitlist signup:\n\nEmail: ' + email + '\n\nDate: ' + new Date().toLocaleString());
    const mailtoLink = 'mailto:' + NOTIFICATION_EMAIL + '?subject=' + subject + '&body=' + body;

    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    iframe.src = mailtoLink;
    document.body.appendChild(iframe);

    setTimeout(() => {
        if (iframe.parentNode) {
            document.body.removeChild(iframe);
        }
    }, 100);

    document.getElementById('formContent').style.display = 'none';
    document.getElementById('successContent').style.display = 'block';
}

function recordPageView() {
    const pageViewCount = document.getElementById('pageViewCount');

    fetch(PAGE_VIEW_ENDPOINT, { cache: 'no-store' })
        .then(response => response.json())
        .then(data => {
            if (pageViewCount && typeof data.count === 'number') {
                pageViewCount.textContent = data.count.toLocaleString();
            }
        })
        .catch(() => {
            if (pageViewCount) {
                pageViewCount.textContent = '—';
            }
        });
}

document.addEventListener('DOMContentLoaded', function() {
    const waitlistButton = document.getElementById('waitlistButton');
    const closeButton = document.getElementById('closeButton');
    const cancelButton = document.getElementById('cancelButton');
    const closeSuccessButton = document.getElementById('closeSuccessButton');
    const waitlistForm = document.getElementById('waitlistForm');
    const modal = document.getElementById('waitlistModal');

    waitlistButton.addEventListener('click', function() {
        triggeringButton = this;
        openWaitlistModal();
    });

    closeButton.addEventListener('click', closeWaitlistModal);
    cancelButton.addEventListener('click', closeWaitlistModal);
    closeSuccessButton.addEventListener('click', closeWaitlistModal);

    waitlistForm.addEventListener('submit', submitWaitlist);

    modal.addEventListener('click', function(event) {
        if (event.target === this) {
            closeWaitlistModal();
        }
    });

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape' && modal.classList.contains('active')) {
            closeWaitlistModal();
        }
    });

    recordPageView();
});

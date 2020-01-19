(function() {
  const updateCountView = (count) => {
    const countElement = document.querySelector("#count");

    countElement.innerHTML = `<span> ${count} </span>`;
  }

  const updateCountServer = (action) => {
    const data = { action };

    fetch('/update', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    }).
    then((response) => response.json()).
    then((data) => {
      updateCountView(data.count);
    }).
    catch((error) => {
      console.error('Error:', error);
    });
  }

  const incrementButton = document.querySelector("#increment-button");
  incrementButton.addEventListener('click', () => updateCountServer('increment'));

  const decrementButton = document.querySelector("#decrement-button");
  decrementButton.addEventListener('click', () => updateCountServer('decrement'));

  const resetButton = document.querySelector("#reset-button");
  resetButton.addEventListener('click', () => updateCountServer('reset'));
}());  

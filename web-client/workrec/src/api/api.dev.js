export default class DevAPI {
  static works = []

  static getWorkList() {
    return new Promise((resolve, reject) => {
      resolve({
        works: this.works
      })
    })
  }

  static addWork(title) {
    return new Promise((resolve, reject) => {
      const index = this.works.length + 1
      this.works = this.works.concat({
        id: `${index}`,
        title: title,
        state: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      resolve({})
    })
  }

  static startWork(id, time) {
    return new Promise((resolve, reject) => {
      resolve({})
    })
  }

  static pauseWork(id, time) {
    return new Promise((resolve, reject) => {
      resolve({})
    })
  }

  static resumeWork(id, time) {
    return new Promise((resolve, reject) => {
      resolve({})
    })
  }

  static finishWork(id, time) {
    return new Promise((resolve, reject) => {
      resolve({})
    })
  }

  static cancelFinishWork(id, time) {
    return new Promise((resolve, reject) => {
      resolve({})
    })
  }

  static deleteWork(id) {
    return new Promise((resolve, reject) => {
      this.works = this.works.filter(work => work.id !== id)
      resolve({})
    })
  }
}

